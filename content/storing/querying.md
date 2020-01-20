### Versioned Query Algorithms
{:#storing_querying}

In this section, we introduce algorithms for performing VM, DM and VQ triple pattern queries
based on the storage structure introduced in [](#storing_storage).
Each of these querying algorithms are based on result streams, enabling efficient offsets and limits,
by exploiting the index structure from [](#storing_storage).
Furthermore, we provide algorithms to provide count estimates for each query.

#### Version Materialization

Version Materialization (VM) is the most straightforward versioned query type,
it allows you to query against a certain dataset version.
In the following, we start by introducing our VM querying algorithm,
after we give a simple example of this algorithm.
After that, we prove the correctness of our VM algorithm and introduce a corresponding algorithm to provide count estimation for VM query results.

##### Query

[](#storing_algorithm-querying-vm) introduces an algorithm for VM triple pattern queries based on our storage structure.
It starts by determining the snapshot on which the given version is based (line 2).
After that, this snapshot is queried for the given triple pattern and offset.
If the given version is equal to the snapshot version, the snapshot iterator can be returned directly (line 3).
In all other cases, this snapshot offset could only be an estimation,
and the actual snapshot offset can be larger if deletions were introduced before the actual offset.

Our algorithm returns a stream where triples originating from the snapshot always
come before the triples that were added in later additions.
Because of that, the mechanism for determining the correct offset in the
snapshot, additions and deletions streams can be split up into two cases.
The given offset lies within the range of either snapshot minus deletion triples or within the range of addition triples.
At this point, the additions and deletions streams are initialized to the start position for the given triple pattern and version.

<figure id="storing_algorithm-querying-vm" class="algorithm numbered">
````/storing/algorithms/querying-vm.txt````
<figcaption markdown="block">
Version Materialization algorithm for triple patterns that produces a triple stream with an offset in a given version.
</figcaption>
</figure>

In the first case, when the offset lies within the snapshot and deletions range (line 11),
we enter a loop that converges to the actual snapshot offset based on the deletions
for the given triple pattern in the given version.
This loop starts by determining the triple at the current offset position in the snapshot (line 13, 14).
We then query the deletions tree for the given triple pattern and version (line 15),
filter out local changes, and use the snapshot triple as offset.
This triple-based offset is done by navigating through the tree to the smallest triple before or equal to the offset triple.
We store an additional offset value (line 16), which corresponds to the current numerical offset inside the deletions stream.
As long as the current snapshot offset is different from the sum of the original offset and the additional offset,
we continue iterating this loop (line 17), which will continuously increase this additional offset value.

In the second case (line 19), the given offset lies within the additions range.
Now, we terminate the snapshot stream by offsetting it after its last element (line 20),
and we relatively offset the additions stream (line 21).
This offset is calculated as the original offset subtracted with the number of snapshot triples incremented with the number of deletions.

Finally, we return a simple iterator starting from the three streams (line 25).
This iterator performs a sort-merge join operation that removes each triple from the snapshot that also appears in the deletion stream,
which can be done efficiently because of the consistent `SPO`-ordering.
Once the snapshot and deletion streams have finished,
the iterator will start emitting addition triples at the end of the stream.
For all streams, local changes are filtered out because locally changed triples
are cancelled out for the given version as explained in [](#storing_local-changes),
so they should not be returned in materialized versions.

##### Example

We can use the deletion's position in the delta as offset in the snapshot
because this position represents the number of deletions that came before that triple inside the snapshot given a consistent triple order.
[](#storing_query-vm-example) shows simplified storage contents where triples are represented as a single letter,
and there is only a single snapshot and delta.
In the following paragraphs, we explain the offset convergence loop of the algorithm in function of this data for different offsets,
when querying all triples in version 1.

<figure id="storing_query-vm-example" class="table" markdown="1">

| Snapshot    | A | B | C | D | E | F |
| ------------|---|---|---|---|---|---|
| Deletions   |   | B |   | D | E |   |
| Positions   |   | 0 |   | 1 | 2 |   |

<figcaption markdown="block">
Simplified storage contents example where triples are represented as a single letter.
The snapshot contains six elements, and the next version contains three deletions.
Each deletion is annotated with its position.
</figcaption>
</figure>

###### _Offset 0_
For offset zero, the snapshot is first queried for this offset,
which results in a stream starting from `A`.
Next, the deletions are queried with offset `A`, which results in no match,
so the final snapshot stream starts from `A`.

###### _Offset 1_
For an offset of one, the snapshot stream initially starts from `B`.
After that, the deletions stream is offset to `B`, which results in a match.
The original offset (1), is increased with the position of `B` (0) and the constant 1,
which results in a new snapshot offset of 2.
We now apply this new snapshot offset.
As the snapshot offset has changed, we enter a second iteration of the loop.
Now, the head of the snapshot stream is `C`.
We offset the deletions stream to the first element on or before `C`, which again results in `B`.
As this offset results in the same snapshot offset,
we stop iterating and use the snapshot stream with offset 2 starting from `C`.

###### _Offset 2_
For offset 2, the snapshot stream initially starts from `C`.
After querying the deletions stream, we find `B`, with position 0.
We update the snapshot offset to 2 + 0 + 1 = 3,
which results in the snapshot stream with head `D`.
Querying the deletions stream results in `D` with position 1.
We now update the snapshot offset to 2 + 1 + 1 = 4, resulting in a stream with head `E`.
We query the deletions again, resulting in `E` with position 2.
Finally, we update the snapshot offset to 2 + 2 + 1 = 5 with stream head `F`.
Querying the deletions results in the same `E` element,
so we use this last offset in our final snapshot stream.

##### Estimated count

In order to provide an estimated count for VM triple pattern queries,
we introduce a straightforward algorithm that depends on the efficiency of the snapshot to provide count estimations for a given triple pattern.
Based on the snapshot count for a given triple pattern, the number of deletions for that version and triple pattern
are subtracted and the number of additions are added.
These last two can be resolved efficiently, as we precalculate
and store expensive addition and deletion counts as explained in [](#storing_addition-counts) and [](#storing_deletion-counts).

##### Correctness

In this section, we provide a proof that [](#storing_algorithm-querying-vm) results in the correct stream offset
for any given version and triple pattern. We do this by first introducing a set of notations,
followed by several lemmas and corollaries, which lead up to our final theorem proof.

**Notations**:

We will make use of bracket notation to indicate lists (ordered sets):

 - `A[i]` is the element at position `i` from the list `A`.
 - `A + B` is the concatenation of list `A` followed by list `B`.

Furthermore, we will use the following definitions:

 - `snapshot(tp, version)` is the ordered list of triples matching the given triple pattern `tp` in the corresponding snapshot, from here on shortened to `snapshot`.
 - `additions(version)` and `deletions(version)` are the corresponding ordered additions and deletions for the given version, from here on shortened to `additions` and `deletions`.
 - `originalOffset` is how much the versioned list should be shifted, from here on shortened to `ori`.
 - `PatchedSnapshotIterator(snapshot, deletions, additions)` is a function that returns the list `snapshot\deletions + additions`.

The following definitions correspond to elements from the loop on lines 12-17:

 - `deletions(x)` is the ordered list `{d | d ∈ deletions, d ≥ x}`, with `x` a triple.
 - `offset(x) = |deletions| - |deletions(x)|`, with `x` a triple.
 - `t(i)` is the triple generated at line 13-14 for iteration `i`.
 - `off(i)` is the offset generated at line 16 for iteration `i`.

**Lemma 1**: `off(n) ≥ off(n-1)`  
*Proof*:  
We prove this by induction over the iterations of the loop.
For `n=1` this follows from line 9 and `∀ x offset(x) ≥ 0.`

For `n+1` we assume that `off(n) ≥ off(n-1)`.
Since `snapshot` is ordered, `snapshot[ori + off(n)] ≥ snapshot[ori + off(n-1)]`.
From lines 13-14 it follows that `t(n) = snapshot[ori + off(n-1)]`,
together this gives `t(n+1) ≥ t(n)`.

From this, we get:

* `{d | d ∈ deletions, d ≥ t(n+1)} ⊆ {d | d ∈ deletions, d ≥ t(n)}`  
* `deletions(t(n+1)) ⊆ deletions(t(n))`  
* `|deletions(t(n+1))| ≤ |deletions(t(n))|`  
* `|deletions| - |deletions(t(n+1))| ≥ |deletions| - |deletions(t(n))|`  
* `offset(t(n+1)) ≥ offset(t(n))`

Together with lines 15-16 this gives us `off(n+1) ≥ off(n)`.

**Corollary 1**: The loop on lines 12-17 always terminates.  
*Proof*:  
Following the definitions, the end condition of the loop is `ori + off(n) = ori + off(n+1)`.
From Lemma 1 we know that `off` is a non-decreasing function.
Since `deletions` is a finite list of triples, there is an upper limit for `off` (`|deletions|`),
causing `off` to stop increasing at some point which triggers the end condition.

**Corollary 2**: When the loop on lines 12-17 terminates, `offset = |{d | d ∈ deletions, d ≤ snapshot[ori + offset]}|` and `ori + offset < |snapshot|`  
*Proof*:  
The first part follows from the definition of `deletions` and `offset`.
The second part follows from `offset ≤ |deletions|` and line 11.

**Theorem 1**: queryVm returns a sublist of `(snapshot\deletions + additions)`, starting at the given offset.  
*Proof*:  
If the given version is equal to a snapshot, there are no additions or deletions so this follows directly from lines 2-4.

Following the definition of `deletions`, `∀ x ∈ deletions: x ∈ snapshot` and thus `|snapshot\deletions| = |snapshot| - |deletions|`.

Due to the ordered nature of `snapshot` and `deletions`, if `ori < |snapshot\deletions|`, version`[ori] = snapshot[ori + |D|]` with `D = {d | d ∈ deletions, d < snapshot[ori + |D|]}`.
Due to `|snapshot\deletions| = |snapshot| - |deletions|`, this corresponds to the if-statement on line 11.
From Corollary 1 we know that the loop terminates
and from Corollary 2 and line 13 that snapshot points to the element at position
`ori + |{d | d ∈ deletions, d ≤ snapshot[ori + offset]}|` which,
together with `additions` starting at index 0 and line 25,
returns the requested result.

If `ori ≥ |snapshot\deletions|`, `version[ori] = additions[ori - |snapshot\deletions|]`.
From lines 20-22 it follows that `snapshot` gets emptied and `additions` gets shifted for the remaining required elements `(ori - |snapshot\deletions|)`, which then also returns the requested result on line 25.

#### Delta Materialization

The goal of delta materialization (DM) queries is to query the triple differences between two versions.
Furthermore, each triple in the result stream is annotated with either being an addition or deletion between the given version range.
Within the scope of this work, we limit ourselves to delta materialization within a single snapshot and delta chain.
Because of this, we distinguish between two different cases for our DM algorithm
in which we can query triple patterns between a start and end version,
the start version of the query can either correspond to the snapshot version or it can come after that.
Furthermore, we introduce an equivalent algorithm for estimating the number of results for these queries.

##### Query

For the first query case, where the start version corresponds to the snapshot version,
the algorithm is straightforward.
Since we always store our deltas relative to the snapshot,
filtering the delta of the given end version based on the given triple pattern directly corresponds to the desired result stream.
Furthermore, we filter out local changes, as we are only interested in actual change with respect to the snapshot.

For the second case, the start version does not correspond to the snapshot version.
The algorithm iterates over the triple pattern iteration scope of the addition and deletion trees in a sort-merge join-like operation,
and only emits the triples that have a different addition/deletion flag for the two versions.

##### Estimated count

For the first case, the start version corresponds to the snapshot version.
The estimated number of results is then the number of snapshot triples for the pattern summed up with the exact umber of deletions and additions for the pattern.

In the second case the start version does not correspond to the snapshot version.
We estimate the total count as the sum of the additions and deletions for the given triple pattern in both versions.
This may only be a rough estimate, but will always be an upper bound, as the triples that were changed twice within the version range and negate each other
are also counted.
For exact counting, this number of negated triples should be subtracted.

#### Version Query

For version querying (VQ), the final query atom, we have to retrieve all triples across all versions,
annotated with the versions in which they exist.
In this work, we again focus on version queries for a single snapshot and delta chain.
For multiple snapshots and delta chains, the following algorithms can simply be applied once for each snapshot and delta chain.
In the following sections, we introduce an algorithm for performing triple pattern version queries
and an algorithm for estimating the total number of matching triples for the former queries.

##### Query

Our version querying algorithm is again based on a sort-merge join-like operation.
We start by iterating over the snapshot for the given triple pattern.
Each snapshot triple is queried within the deletion tree.
If such a deletion value can be found, the versions annotation contains all versions except for the versions
for which the given triple was deleted with respect to the given snapshot.
If no such deletion value was found, the triple was never deleted,
so the versions annotation simply contains all versions of the store.
Result stream offsetting can happen efficiently as long as the snapshot allows efficient offsets.
When the snapshot iterator is finished, we iterate over the addition tree in a similar way.
Each addition triple is again queried within the deletions tree
and the versions annotation can equivalently be derived.

##### Estimated count

Calculating the number of unique triples matching any triple pattern version query is trivial.
We simply retrieve the count for the given triple pattern in the given snapshot
and add the number of additions for the given triple pattern over all versions.
The number of deletions should not be taken into account here,
as this information is only required for determining the version annotation in the version query results.
