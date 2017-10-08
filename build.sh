set -eux

export LANG="ja_JP.UTF-8"

#cat /usr/local/texlive/2016/texmf-dist/tex/latex/listings/listings.sty

rm -rf target
mkdir -p target

OUTPUT="sweetmusic-vol4"

for file in `ls src/*.md`
do
  cat $file >> target/tmp.md
  cat src/newpage.txt >> target/tmp.md
done
cat src/990*.yaml >> target/tmp.md

cat -n target/tmp.md

pandoc -V fontsize:12pt -V papersize:b5 -V documentclass=ltjsarticle -s -f markdown+raw_tex+citations+yaml_metadata_block+fenced_code_blocks --filter pandoc-crossref -M "crossrefYaml=${PWD}/crossref_config.yaml" --filter pandoc-citeproc -o target/${OUTPUT}.pdf --latex-engine=lualatex -H h-luatexja.tex -A src/imprint.tex  --toc --toc-depth=2 -S target/tmp.md  --verbose
cat src/epub.yaml >> target/tmp.md
pandoc -V fontsize:12pt -V papersize:b5 -s -f markdown+raw_tex+citations+yaml_metadata_block+fenced_code_blocks+ignore_line_breaks --filter pandoc-crossref -M "crossrefYaml=${PWD}/crossref_config.yaml" --filter pandoc-citeproc -t epub3 -o target/${OUTPUT}.epub --latex-engine=lualatex -H h-luatexja.tex  --toc --toc-depth=2 -S  target/tmp.md  --verbose

RET=$?
set +e
/opt/redpen-distribution-1.9.0/bin/redpen -c redpen-config.xml -f markdown src/*.md |tee target/${OUTPUT}.txt

exit $RET
