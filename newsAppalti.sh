#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/dati

# scarica dati di base
curl "https://portaleappalti.comune.palermo.it/PortaleAppalti/it/ppgare_doc_news.wp" |
  # pulisci l'HTML
  tidy -q --show-warnings no --drop-proprietary-attributes y --show-errors 0 --force-output y |
  # estrai le informazioni
  scrape -be '//form/div[@class="list-item"]' | xq '.html.body.div[]|{data:.div[0]."#text",oggetto:.div[1]."#text",testo:.div[2]."#text",riferimento:.div[3]."#text",titolo:.div[4]."#text",url:.div[5].a."@href"}' |
  # rimuovi "a capo"
  sed 's/\\n/ /g' |
  # converti json in TSV
  mlr --j2t clean-whitespace >"$folder"/dati/news.tsv
