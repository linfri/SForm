#-------------------------------------------------------------------------------
# SForm app by Linn Friberg (https://github.com/linfri)
#-------------------------------------------------------------------------------
#
# Uploads file and form data (CSV) to Dropbox.
#
# Compilation call text (HTML): compilationcall.txt
# Submission procedure text (HTML): procedure.txt
# Producer name (HTML): producer.txt
# Link to Facebook event (HTML): fbevent.txt
# Deadline: deadline.txt (YYYY-MM-DD, coercing to date)
#
# Generate token via token.R first, otherwise will produce an error.
# Supports GDPR, disabled by default.
#
#-------------------------------------------------------------------------------

library(shiny)
library(shinyjs)
library(shinybulma)
library(rdrop2)
library(lubridate)

# File size restriction (150 MB, changeable but not recommended with Dropbox)
# If changed anyway, change the text in procedure.txt too.
options(shiny.maxRequestSize = 150 * 1024^2)

# GDPR implementation, if collecting emails. Default: FALSE
isGDPR <- FALSE

# Defines UI for the form.
ui <- bulmaPage(
  theme = "lux",
  bulmaHero(
    fullheight = TRUE,
    bold = TRUE,
    color = "primary",
    bulmaHeroBody(
      bulmaContainer(
        
        # Form title (changeable)
        bulmaTitle("Submission Form"),

        # Label name (changeable)
        bulmaSubtitle("Kalamine Records")
      ),
      bulmaSection(
        bulmaTileAncestor(
          bulmaTileParent(
            vertical = TRUE,
            bulmaTileChild(
              bulmaSubtitle("Information"),
              color = "primary",
              uiOutput(HTML("compCall")),
              uiOutput("deadlineTxt"),
              uiOutput("producer"),
              uiOutput("fbEvent")
            )
          ),
          bulmaTileParent(
            vertical = TRUE,
            bulmaTileChild(
              bulmaSubtitle("Submission Procedure"),
              color = "info",
              uiOutput(HTML("submProc")),
              textInput("artist", h6("Artist Name"),
                placeholder = "Enter text..."
              ),
              textInput("track", h6("Track Name"),
                placeholder = "Enter text..."
              ),
              textInput("country", h6("Country"),
                placeholder = "Enter text..."
              ),
              textInput("email", h6("E-mail"),
                placeholder = "Enter text..."
              ),
              textInput("link1", h6("Website"),
                placeholder = "Enter text..."
              ),
              checkboxInput("gdpr", "I consent to the processing of my personal data according to GDPR")
            ),
            bulmaTileChild(
              color = "link",

              # Using standard fileInput, shinybulma does not have its own.
              fluidPage(
                useShinyjs(),
                fileInput("file1",
                  label = "Select Audio File",
                  multiple = FALSE,
                  accept = c("audio/wav", "audio/aiff", ".flac"),
                  buttonLabel = "Browse...",
                  placeholder = "No file selected"
                ),
              )
            )
          )
        )
      )
    )
  ),
)

# Defines server logic for the form.
server <- function(input, output, session) {

  # Checking whether the token & the text files exist.
  if (!file.exists("ee977806d7286510da") |
    !file.exists("compilationcall.txt") |
    !file.exists("procedure.txt") |
    !file.exists("producer.txt") |
    !file.exists("deadline.txt") |
    !file.exists("fbevent.txt")) {
    bulmaAlert(
      list(
        type = "danger",
        title = "Error",
        body = "Configuration error! Required files are missing.",
        confirm = "OK",
        showHeader = TRUE
      )
    )
    Sys.sleep(3)
    break
  }

  # Disable GDPR if unused.
  observe({
    if (isGDPR == FALSE) {
      shinyjs::hide("email")
      shinyjs::hide("gdpr")
    } else {
      shinyjs::show("email")
      shinyjs::show("gdpr")
    }
  })

  # Defining deadline. The next day after the deadline the form locks down.
  deadline <- as.Date(readLines("deadline.txt"))
  if (today() > deadline) {
    formClosed <- TRUE
  } else {
    formClosed <- FALSE
  }

  # If submissions closed, disable uploading.
  observe({
    if (formClosed == TRUE) {
      shinyjs::disable("file1")
      shinyjs::disable("artist")
      shinyjs::disable("track")
      shinyjs::disable("country")
      shinyjs::disable("link1")
      if (isGDPR == TRUE) {
        shinyjs::disable("email")
        shinyjs::disable("gdpr")
      }
    } else {
      shinyjs::enable("file1")
      shinyjs::enable("artist")
      shinyjs::enable("track")
      shinyjs::enable("country")
      shinyjs::enable("link1")
      if (isGDPR == TRUE) {
        shinyjs::enable("email")
        shinyjs::enable("gdpr")
      }
    }
  })

  # Displays the compilation call.
  # If submissions closed, displaying the message.
  output$compCall <- renderUI({
    if (formClosed == TRUE) {
      return(HTML("<b>Submissions closed! Please come back another time.</b>"))
    } else {
      compText <- readLines("compilationcall.txt")
      return(HTML(compText))
    }
  })

  # Displays the submission procedure.
  output$submProc <- renderUI({
    procText <- readLines("procedure.txt")
    return(HTML(procText))
  })

  # Displays the deadline.
  output$deadlineTxt <- renderUI({
    return(HTML(paste0("<br/><b>Deadline:</b> ", as.character(deadline))))
  })

  # Displays the producer name.
  output$producer <- renderUI({
    return(HTML(paste0("<b>Producer:</b> ", readLines("producer.txt"))))
  })

  # Displays the Facebook link.
  output$fbEvent <- renderUI({
    return(HTML(paste0("<b>Facebook event:</b> ", readLines("fbevent.txt"))))
  })

  # Displays the GDPR consent message.
  observeEvent(input$gdpr, {
    if (input$gdpr == TRUE) {
      bulmaAlert(
        list(
          type = "info",
          title = "GDPR Consent",
          body = "The European General Data Protection Regulation (GDPR) requires that all work with personal data should be done transparently, correctly, and securely. By submitting your track to the compilation you consent to collecting and processing data (your artist name, track name, country, e-mail, and website link) within the scope of compilation production, which includes the automatic transfer of data to/from a Dropbox account of the compilation producer, automatic generation of text files (containing country information and the website links) for Bandcamp and public Facebook events, and storage of anonymized statistics for research purposes. The compilation producer guarantees that the source code of the submission form and the utility scripts, published on GitHub, have not been modified for any other purpose than the one stated above. The compilation producer cannot be held liable for a data breach that occurred through the usage of external cloud services (Dropbox and shinyapps.io), and/or for any malfunction caused by the submission form and/or the utility scripts. Please contact the compilation producer in case you wish to amend or delete your personal data after the submission of your track took place.",
          confirm = "OK",
          showHeader = TRUE
        )
      )
    }
  })


  # The following is triggered when uploading a file.
  observeEvent(input$file1, {
    req(input$file1)

    # Checking whether the file is WAV or AIFF.
    if (tools::file_ext(input$file1) != "wav" &
      tools::file_ext(input$file1) != "aiff" &
      tools::file_ext(input$file1) != "flac") {
      bulmaAlert(
        list(
          type = "danger",
          title = "Cannot Submit Music",
          body = "Please select a WAV, FLAC or AIFF file!",
          confirm = "OK",
          showHeader = TRUE
        )
      )
      shinyjs::reset("file1")
    } else {

      # If the format is right, looking at the state of isGDPR. If false...
      if (isGDPR == FALSE) {

        # Checking whether all the form fields are filled out.
        if (input$artist == "" | input$track == "" |
          input$country == "" | input$link1 == "") {
          bulmaAlert(
            list(
              type = "danger",
              title = "Cannot Submit Music",
              body = "Please fill in all the fields!",
              confirm = "OK",
              showHeader = TRUE
            )
          )
          shinyjs::reset("file1")
        } else {

          # And if they are, displaying a progress bar...
          # ...and uploading the file and form data to Dropbox.

          withProgress(message = "Working...", value = 1, {
            dataF <- data.frame(input$artist, input$track, input$country, input$link1)
            colnames(dataF) <- c("Artist", "Track", "Country", "Website")
            write.csv(dataF, paste0(input$file1$name, ".csv"))
            token <- readRDS("ee977806d7286510da")
            drop_upload(input$file1$datapath, path = input$file1$name, dtoken = token)
            drop_upload(paste0(input$file1$name, ".csv"), path = input$file1$name, dtoken = token)

            # When done, displaying the message.
            bulmaAlert(
              list(
                type = "success",
                title = "Submission Successful",
                body = "Your music submission has been transferred to us. The tracklists will be published within the Facebook event.",
                confirm = "OK",
                showHeader = TRUE
              )
            )

            # Resetting the fields. We are done here.
            shinyjs::reset("file1")
            shinyjs::reset("artist")
            shinyjs::reset("track")
            shinyjs::reset("country")
            shinyjs::reset("link1")
          })
        }

        # And if isGDPR is true, proceeding here...
      } else {

        # Checking whether all the form fields are filled out.
        # This time email input and the checkbox are in.
        if (input$artist == "" | input$track == "" |
          input$country == "" | input$link1 == "" |
          input$email == "" | input$gdpr == FALSE) {
          bulmaAlert(
            list(
              type = "danger",
              title = "Cannot Submit Music",
              body = "Please fill in all the fields!",
              confirm = "OK",
              showHeader = TRUE
            )
          )
          shinyjs::reset("file1")
        } else {

          # If everything is alright, displaying a progress bar...
          # and uploading the file and form data to Dropbox.
          # Here we are collecting emails (personal data per GDPR).
          withProgress(message = "Working...", value = 1, {
            dataF <- data.frame(input$artist, input$track, input$country, input$link1, input$email)
            colnames(dataF) <- c("Artist", "Track", "Country", "Website", "Email")
            write.csv(dataF, paste0(input$file1$name, ".csv"))
            token <- readRDS("ee977806d7286510da")
            drop_upload(input$file1$datapath, path = input$file1$name, dtoken = token)
            drop_upload(paste0(input$file1$name, ".csv"), path = input$file1$name, dtoken = token)

            # When done, displaying the message and resetting the fields.
            bulmaAlert(
              list(
                type = "success",
                title = "Submission Successful",
                body = "Your music submission has been transferred to us. The tracklists will be published within the Facebook event.",
                confirm = "OK",
                showHeader = TRUE
              )
            )
            shinyjs::reset("file1")
            shinyjs::reset("artist")
            shinyjs::reset("track")
            shinyjs::reset("country")
            shinyjs::reset("link1")
            shinyjs::reset("gdpr")
            shinyjs::reset("email")
          })
        }
      }
    }
  })
}

shinyApp(ui, server)
