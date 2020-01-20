### Problem statement
{:#storing_problem-statement}

As mentioned in [](#storing_introduction), no RDF archiving solutions exist that allow
efficient triple pattern querying _at_, _between_, and _for_ different versions,
in combination with a scalable _storage model_ and efficient _compression_.
In the context of query engines, streams are typically used to return query results,
on which offsets and limits can be applied to reduce processing time if only a subset is needed.
Offsets are used to skip a certain amount of elements,
while limits are used to restrict the number of elements to a given amount.
As such, RDF archiving solutions should also allow query results to be returned as offsettable streams.
The ability to achieve such stream subsets is limited in existing solutions.

This leads us to the following research question:

<div rel="schema:question" markdown="1">
> How can we store RDF archives to enable efficient VM, DM and VQ triple pattern queries with offsets?
{:#storing_researchquestion about="#storing_researchquestion" property="schema:name"}
</div>

The focus of this article is evaluating version materialization (VM), delta materialization (DM), and version (VQ) queries efficiently,
as CV and CM queries can be expressed in [terms of the other ones](cite:cites tpfarchives).
In total, our research question identifies the following requirements:

- an efficient RDF archive storage technique;
- VM, DM and VQ triple pattern querying algorithms on top of this storage technique;
- efficient offsetting of the VM, DM, and VQ query result streams.

In this work, we lower query evaluation times by processing and storing more metadata during ingestion time.
Instead of processing metadata during every lookup, this happens only once per version.
This will increase ingestion times, but will improve the efficiency of performance-critical features
within query engines and Linked Data interfaces, such as querying with offsets.
To this end, we introduce the following hypotheses:

<div rel="lsc:tests" markdown="1">
1. {:#storing_hypothesis-qualitative-querying about="#storing_hypothesis-qualitative-querying" property="schema:name"}
Our approach shows no influence of the selected versions on the querying efficiency of VM and DM triple pattern queries.
2. {:#storing_hypothesis-qualitative-ic-storage about="#storing_hypothesis-qualitative-ic-storage" property="schema:name"}
Our approach requires *less* storage space than state-of-the-art IC-based approaches.
3. {:#storing_hypothesis-qualitative-ic-querying about="#storing_hypothesis-qualitative-ic-querying" property="schema:name"}
For our approach, querying is *slower* for VM and *equal* or *faster* for DM and VQ than in state-of-the-art IC-based approaches.
4. {:#storing_hypothesis-qualitative-cb-storage about="#storing_hypothesis-qualitative-cb-storage" property="schema:name"}
Our approach requires *more* storage space than state-of-the-art CB-based approaches.
5. {:#storing_hypothesis-qualitative-cb-querying about="#storing_hypothesis-qualitative-cb-querying" property="schema:name"}
For our approach, querying is *equal* or *faster* than in state-of-the-art CB-based approaches.
6. {:#storing_hypothesis-qualitative-ingestion about="#storing_hypothesis-qualitative-ingestion" property="schema:name"}
Our approach reduces average query time compared to other non-IC approaches at the cost of increased ingestion time.
</div>
