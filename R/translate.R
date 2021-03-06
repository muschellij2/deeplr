translate <- function(dataset = NULL,
                      column.name = NULL,
                      source.lang = "EN",
                      target.lang = "DE",
                      url = "https://www.deepl.com/jsonrpc"
                      ) {



# INPUT: Character vector of length 1 ####
if(inherits(dataset,"character")==TRUE&length(dataset)==1){
    response <- httr::POST(url = url,

                     body = paste('{"jsonrpc":"2.0","method":"LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"',
                                  dataset,
                                  '"}],"lang":{"user_preferred_langs":["EN","PL","NL"],"source_lang_user_selected":"',
                                  source.lang,
                                  '","target_lang":"',
                                  target.lang,
                                  '"},"priority":-1},"id":29}', sep=""))
    respcontent <- httr::content(response, as="text", encoding = "UTF-8")
    return(jsonlite::fromJSON(respcontent)$result$translations$beams[[1]]$postprocessed_sentence[1])
}



# INPUT: Character vector of length > 1 ####
if(inherits(dataset,"character")==TRUE&length(dataset)>1){
    responses <- NULL
    z <- 0
    for(i in dataset){
      svMisc::progress(z, max.value = length(dataset))
      z <- z+1

      response.i <- httr::POST(url = url,

                       body = paste('{"jsonrpc":"2.0","method":"LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"',
                                    i,
                                    '"}],"lang":{"user_preferred_langs":["EN","PL","NL"],"source_lang_user_selected":"',
                                    source.lang,
                                    '","target_lang":"',
                                    target.lang,
                                    '"},"priority":-1},"id":15}', sep=""))
      respcontent.i <- httr::content(response.i, as="text", encoding = "UTF-8")
      result.i <- jsonlite::fromJSON(respcontent.i)$result$translations$beams[[1]]$postprocessed_sentence[1]
      responses <- c(responses, result.i)
    }
    return(responses)

}



# INPUT: Dataframe with text in column ####
  if(inherits(dataset,"data.frame")==TRUE&!is.null(column.name)){

    dataset2 <- dataset %>% dplyr::pull(column.name) %>% as.character()

    responses <- NULL
    z <- 0
    for(i in dataset2){
      svMisc::progress(z, max.value = length(dataset2))
      z <- z+1
      i <- stringr::str_replace(gsub("\\s+", " ", stringr::str_trim(i)), "B", "b")
      response.i <- httr::POST(url = url,

                         body = paste('{"jsonrpc":"2.0","method":"LMT_handle_jobs","params":{"jobs":[{"kind":"default","raw_en_sentence":"',
                                      i,
                                      '"}],"lang":{"user_preferred_langs":["EN","PL","NL"],"source_lang_user_selected":"',
                                      source.lang,
                                      '","target_lang":"',
                                      target.lang,
                                      '"},"priority":-1},"id":15}', sep=""))
      respcontent.i <- httr::content(response.i, as="text", encoding = "UTF-8")
      result.i <- jsonlite::fromJSON(respcontent.i)$result$translations$beams[[1]]$postprocessed_sentence[1]
      responses <- c(responses, result.i)
    }
    dataset <- cbind(dataset, translation = responses)
    return(dataset)
  }

  if(inherits(dataset,"data.frame")==TRUE&is.null(column.name)){cat("If input is a data.frame you have to specify a column name, e.g. translate(dataset = dat, column.name = 'text'.")}

}








