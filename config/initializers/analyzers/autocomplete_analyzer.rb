AutocompleteAnalyzer = { 
  :number_of_shards => 1,
  :number_of_replicas => 1,
  analysis: {
    filter: {
      autocomplete_ngram: {
        "type"     => "nGram",
        "max_gram" => 16,
        "min_gram" => 3
      }
    },
    analyzer: {
      autocomplete: {
        "tokenizer"    => "lowercase",
        "filter"       => ["autocomplete_ngram"],
        "type"         => "custom" 
      }
    }
  }
}