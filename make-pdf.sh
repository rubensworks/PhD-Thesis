PAGE_START="20" # The first page of chapter 1
PAGE_END="171" # The last references page (there must be 2 empty pages after this one)

chrome-headless-render-pdf --url http://localhost:3000/ --pdf article.pdf --paper-width 8.27 --paper-height 11.69 --no-margins \
#    --display-header-footer --header-template ' ' \
#    --footer-template '<style type="text/css">.footer{font-size:8px;width:100%;text-align:right;color:#000;padding:0.65cm;}</style><div class="footer"><span class="pageNumber"></span> / <span class="totalPages"></span></div>'

# Make print-version (with page-numbers)
# Install pspdftool from https://sourceforge.net/projects/pspdftool/
# Man page: http://rpm.pbone.net/index.php3/stat/45/idpl/21931990/numer/1/nazwa/pspdftool
# Downside: links in PDFs are removed
# Page number positioning: even: left; odd: right
pspdftool "apply{$PAGE_START..$PAGE_END number(x=290pt, y=90pt, start=20, size=8)}" article.pdf article-paged.pdf

# Replace generated title page with ugent-provided title page
pdfjoin --rotateoversize false --outfile article-print.pdf article-paged.pdf '1-2' titlepage.pdf '-' article-paged.pdf '5-'

# Cleanup intermediary files
rm article-paged.pdf