library(shiny)
library(wordcloud)
library(tm)
library(SnowballC)
library(tidytext)
library(reshape2)
library(dplyr)
#libraries to load along with server code

Server <- (function(input, output) {

  finalinput <- reactive({

    # Outputs message when neither text is entered nor a text file is uploaded
    validate(
      need((input$text != "") || (!is.null(input$file)),
        "Please enter text to begin"
      )
    )

    # If text input is not empty then get corpus
    # else load text from uploaded text file
    if (nchar(input$text) > 0){
      words <- Corpus(VectorSource(input$text))
    }
    else if (!is.null(input$file)){
      a <- readLines(input$file$datapath)
      a <- substr(a, 1, nchar(a) - 1)
      words <- Corpus(VectorSource(a))
    }

    # Cleaning the corpus
    words <- tm_map(words, stripWhitespace)
    words <- tm_map(words, content_transformer(tolower))
    words <- tm_map(words, removeNumbers)
    words <- tm_map(words, removeWords, stopwords("SMART"))
    words <- tm_map(words, removePunctuation)
    removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
    words <- tm_map(words, content_transformer(removeSpecialChars))
    stop_words <- unlist(strsplit(input$stop, ","))
    words <- tm_map(words, removeWords, stop_words)
    # if checkbox1 is selected then document is stemmed
    # else text is not stemmed
    if (input$checkbox1) words_stemmed <- tm_map(words, stemDocument)
    else words <- words
    })

  # Reactive expression to transform the data on basis of checkbox3 selection
  rep_cloud <- reactive({
    if (input$checkbox3) wordcloud_rep <- repeatable(wordcloud)
    else wordcloud_rep <- wordcloud
    })

  # Reactive expression to generate the wordcloud and save it as a png
  make_cloud <- reactive ({
    wordcloud_rep <- rep_cloud()

    png("wordcloud.png", width=10, height=8, units="in", res=350)
    w <- wordcloud_rep(finalinput(),
      scale=c(5, 0.5),
      min.freq=input$slider1,
      max.words=input$slider3,
      random.order=input$checkbox2,
      rot.per=input$slider2,
      use.r.layout=FALSE,
      colors=brewer.pal(9, input$color))
    dev.off()

    filename <- "wordcloud.png"
    })

  # Download handler for the wordcloud image
  output$wordcloud_img <- downloadHandler(
    filename = "wordcloud.png",
    content = function(cloud) {
      file.copy(make_cloud(), cloud)
    })

  # Download handler for the freq csv
  output$freq_csv <- downloadHandler(
    filename = "freq.csv",
    content = function(freq) {
      a <- DocumentTermMatrix(finalinput())
      b <- sort(colSums(as.matrix(a)), decreasing=TRUE)
      write.csv(b, freq)
    })

  # Sending the wordcloud image to be rendered
  output$wordcloud <- renderImage({
    list(src=make_cloud(), alt="Image being generated!", height=600)
  },
  deleteFile = FALSE)

  # Reactive expression to transform data from finalinput()
  U_tdm <- reactive ({
     tdm <- TermDocumentMatrix(finalinput())
     M_tdm <- as.matrix(tdm)
     M_tdm <- sort(rowSums(M_tdm), decreasing=TRUE)
     F_tdm <- data.frame(word = names(M_tdm), Freqs=M_tdm)
    })

  # Reactive expression to run sentiment and validate that text contains positive and negative words
  compInput <- reactive ({
    comp_Input <- U_tdm() %>%
      inner_join(get_sentiments("bing"))
    validate(
      need(nrow(comp_Input) != 0,
           "The entered text does not currently contain any positive or negative words"
      )
    )
    comp_Input <- acast(comp_Input, word ~ sentiment, value.var = "Freqs", fill = 0)
    validate(
      need(ncol(comp_Input) != 1,
           "The entered text does not currently contain both positive and negative words"
      )
    )
    comp_Input
  })


  # Reactive expression to generate comparison cloud
  make_Ccloud <- reactive ({
    png("ComparisonCloud.png", width=10, height=8, units="in", res=350)
    comparison.cloud(compInput(), colors = c("red3", "green3"),
    max.words=input$slider3, random.order=input$checkbox2, rot.per=input$slider2, use.r.layout=FALSE, title.size=3, match.colors=TRUE)
    dev.off()

    filename <- "ComparisonCloud.png"
    })

  # Sending the comparisoncloud image to be rendered
  output$comparisoncloud <- renderImage({
    list(src=make_Ccloud(), alt="Image being generated!", height=600)
  },
  deleteFile = FALSE)
  
  # Download handler for the Ccloud image
  output$Ccloud_img <- downloadHandler(
    filename = "ComparisonCloud.png",
    content = function(Ccloud) {
      file.copy(make_Ccloud(), Ccloud)
    })
  
  # Download handler for the sentiment csv
  output$Cfreq_csv <- downloadHandler(
    filename = "Cfreq.csv",
    content = function(Cfreq) {
      a <- compInput()
      write.csv(a, Cfreq)
    })

})

shinyApp(ui = UI, server = Server)