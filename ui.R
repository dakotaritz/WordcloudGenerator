library(shiny)
library(shinythemes)

UI <- (fluidPage(
  theme = shinytheme('darkly'),
  # Title of the app
  titlePanel("Wordcloud Generator"),

  sidebarLayout(
    sidebarPanel(

      # Text box to input the text
      textAreaInput("text", "Text input:"),

      # Text file uploader
      fileInput("file", "Text file:", accept=c("text/plain", ".txt")),

      # Text box to input custom stop words
      textInput("stop", "Enter specific words to remove (separated by commas):"),	

      strong("Settings:"),

      # Checkboxes for wordcloud settings
      checkboxInput("checkbox1", label = "Document stemming", value = FALSE),
      checkboxInput("checkbox2", label = "Random Order", value = FALSE),
      checkboxInput("checkbox3", label = "Repeatable", value = TRUE),

      # Selection input for color change
      selectInput("color", "Color:", choices = c("Yellow to Red" = "YlOrRd", "Yellow to Brown" = "YlOrBr", "Yellow to Blue" = "YlGnBu", 
                                                 "Yellow to Green" = "YlGn", "Reds", "Red to Purple" = "RdPu", "Purples", "Purple to Red" = "PuRd", 
                                                 "Purple to Green" = "PuBuGn", "Purple to Blue" = "PuBu", "Orange to Red" = "OrRd", "Oranges", "Greys",
                                                 "Greens", "Green to Blue" = "GnBu", "Blue to Purple" = "BuPu", "Blue to Green" = "BuGn", "Blues",
                                                 "Pastel" = "Set2", "Pastel and Standard" = "Paired", "High Contrast" = "Dark2"), selected = "YlOrRd"),

      # Slider input for frequency change
      sliderInput("slider1", "Minimum Frequency:",
        min = 1, max = 50, value = 2),

      # Slider input for rotation change
      sliderInput("slider2", "Rotation:",
        min = 0.0, max = 1.0, value = 0.35),

      # Slider input for number of words change
      sliderInput("slider3", "Max words:",
        min = 10, max = 500, value = 100)),

    mainPanel(
      tabsetPanel(
        tabPanel("Wordcloud",
                 # Image download button
                 downloadButton("wordcloud_img", "Download Image"),
                 # CSV download button
                 downloadButton("freq_csv", "Download Freq CSV"),
                 # Wordcloud image
                 imageOutput("wordcloud")),
        tabPanel("Sentiment Comparison",
                 # Image download button
                 downloadButton("Ccloud_img", "Download Image"),
                 # CSV download button
                 downloadButton("Cfreq_csv", "Download Freq CSV"),
                 # Comparisoncloud image
                 imageOutput("comparisoncloud")))
  ))
))