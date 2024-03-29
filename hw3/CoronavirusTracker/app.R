#
# This is a Shiny web application. Developed by Burson Tang, UID: 305068045
library(shiny)

# Source helpers ----
# source("helpers.R")
eval(parse("helpers.R", encoding="UTF-8"))
# Define UI for application in navbarPage ----------
ui <- navbarPage(
    title = "Conronavirus Visualization App",
    tabPanel("China",
             
             ## Plot the distribution map
             sidebarLayout(
                 
                 sidebarPanel(
                     titlePanel("Coronavirus Case Distribution Map"),
                     
                     # selectInput("Case_type_c", label = "Data Type",
                     #             choices = c("Cumulative" = "cumulative",
                     #                         "Incremental" = "incremental")),
                     
                     dateInput("Date_chm", label = "Date",
                               # use the day before today cause time dif
                               value = "2020-05-20", #as.character(Sys.Date()-days(10)),
                               format = "yyyy-mm-dd"
                     ),
                     
                     selectInput("Case_chm", label = "Case Type",
                                 choices = c("Confirmed" = "confirmed",
                                             "Death" = "death",
                                             "Recovered" = "recovered")
                     ),
                     # change the height of the sidebarpanel
                     style = "height: 450px"
                 ),
                 mainPanel(
                     plotOutput("ChinaMap", height = "450px"),
                     # change the padding of the wellPanel, also
                     # make the height consistent with sidebarpanel
                     # style = "padding: 5px;height: 450px"
                 )
             ),
             
             # add separating space line here maybe?
             br(),
             br(),
             ## Plot the time series of Coronavirus
             wellPanel(
                 titlePanel("Coronavirus Case Timeseries"),
                 checkboxGroupInput("TS_Case", "Choose cases to plot",
                                    choices = c("Confirmed" = "confirmed",
                                                "Death" = "death",
                                                "Recovered" = "recovered"),
                                    selected = c("Confirmed" = "confirmed",
                                                 "Death" = "death",
                                                 "Recovered" = "recovered"),
                                    inline = TRUE
                 ),
                 # make the space height as small as 5px, shrink space gray area
                 style = "padding: 5px"
             ),
             
             # Use columns to plot two figures: cumulative, and daily increase
             # plotOutput("ChinaTS_inc", width = "75%")
             fluidRow(
                 column(6, plotOutput("ChinaTS_cum", width = "100%")),
                 column(6, plotOutput("ChinaTS_inc", width = "100%"))
             ),
             
             br(),
             br(),
             
             fluidRow(
                 column(12,h2("The Data table for above time series")),
                 column(4, selectInput("Date_T", "Date:",
                                       c("All", 
                                         unique(as.character(ncov_tbl$Date))
                                       )
                 )
                 ),
                 column(4, selectInput("Province_T", "Province/Region:",
                                       c("All",
                                         unique(as.character(
                                             ncov_tbl$`Province/State`))
                                       )
                 )
                 ),
                 column(4, selectInput("Case_T", "Case:",
                                       c("All", 
                                         unique(as.character(ncov_tbl$Case))
                                       )
                 )
                 ),
                 wellPanel(DT::dataTableOutput("table_CH"))
                 
             )
    ),
    
    tabPanel("World",
             sidebarLayout(
                 sidebarPanel(titlePanel("World Wide Coronavirus Case Distribution"),
                              helpText("Change the selection to start ploting"),
                              helpText("Click the circle on the map for detials"),
                              # selectInput("Case_type_w", label = "Data Type",
                              #             choices = c("Cumulative" = "cumulative",
                              #                         "Incremental" = "incremental")),
                              dateInput("Date_w", label = "Date",
                                        # use the day before today cause time dif
                                        value = as.character(Sys.Date()-days(1)),
                                        format = "yyyy-mm-dd"
                                        ),
                          
                              selectInput("Case_w", label = "Case Type",
                                          choices = c("Confirmed" = "confirmed",
                                                      "Death" = "death",
                                                      "Recovered" = "recovered")
                                          ),
                              style = "height: 450px; padding: 5px;"
                              ),
                 mainPanel(leafletOutput("mymap", height = 450))
                 ),
             br(),
             br(),
             sidebarLayout(
                 sidebarPanel(
                     titlePanel("Coronavirus case histogram for country other than China"),
                     
                     # For debugging
                     # textOutput("debugtext"),
                     
                     dateInput("Date_bp", label = "Date to Display",
                               # use the day before today cause time dif
                               value = "2021-01-12",
                               format = "yyyy-mm-dd"
                     ),
                     br(),
                     br(),
                     sliderInput("range_bp",
                                 "Plot country with historical confirmed case in the range",
                                 min = 1, max = 90000000, value = c(10000000,90000000)), # min = 1, max = 5000, value = c(200,3000)),
                     # make the space height as small as 5px, shrink space gray area
                     style = "height: 380px; padding: 5px"
                 ),
                 
                 mainPanel(
                     plotOutput("Barplot", width = "100%")
                 )

             ),
    )
)


# Define server logic for plots and tables ------------
server <- function(input, output) {
    
    # # For debug
    plotdate <- "2020-05-08"
    case <- "confirmed"
    
    # # Distribution map in china
    output$ChinaMap <- renderPlot({
        # # print input date and case
        # if (is.na(input$Date_chm)){
        #     print('something')
        #     }
        # else{
        #         print(input$Date_chm)
        #         print(input$Case_chm)
        #     }
        ncov_ch_tbl %>%
            # filter(`Country/Region` %in% c("China", "Taiwan*")) %>%
            # # replace the NA State as Taiwan
            # mutate("Province/State" = str_replace_na(`Province/State`,
            #                                          replacement = "Taiwan"))%>%
            # filter(Date == plotdate, Case == case) %>%
            filter(Date == input$Date_chm, #"2020-04-02"
                   Case == input$Case_chm) %>% #"confirmed"
            # group_by(`Province/State`) %>%
            # top_n(1, Date) %>% # take the latest count on that date
            right_join(chn_prov, by = c("Province/State" = "NAME_ENG")) %>%
            ggplot() +
            geom_sf(mapping = aes(fill = Count, geometry = geometry)) +
            scale_fill_gradient(low = "white",
                                high = cl_case[input$Case_chm],
                                trans = "log10",
                                na.value = "white",
                                # limits = c(1, 60000),
                                # breaks = c(1, 10, 100, 1000, 10000),
                                name = "") +
            # scale_fill_gradientn(colors = wes_palette("Zissou1", 100, type = "continuous"),
            #                      trans = "log10") + # can we find a better palette?
            # #scale_fill_brewer(palette = "Dark2") +
            theme_bw() +
            theme(text = element_text(size=20))+
            labs(title = str_c(
                "Daily Increased ", str_to_title(input$Case_chm), " Cases"
                ), 
                 subtitle = input$Date_chm)
    })
    
    ## time series of different cases in China
    # cumulative count
    output$ChinaTS_cum <- renderPlot({
        ncov_tbl %>%
            filter(`Country/Region` %in% c("China", "Taiwan*")) %>%
            # group_by(input$date, input$Case) %>%
            group_by(Date, Case) %>%
            summarise(total_count = sum(Count)) %>%
            filter(Case %in% c(input$TS_Case)) %>%
            # filter(Case %in% c(Confirmed, Death, Recovered)) %>%
            # print()
            ggplot() +
            geom_line(mapping = aes(x = Date, y = total_count, color = Case),
                      size = 2) +
            
            # Old method
            # scale_color_manual(values = c("red", "black", "green")) +
            
            # Assign color to the specific variable instead
            scale_color_manual(values = cl_case) +
            # get rid of scientific notation
            scale_y_continuous(labels = comma)+  
            labs(y = "Count") +
            theme_bw()+
            theme(text = element_text(size=20))+
            labs(title = "Time Series of Cumulative Count")
    })
    
    # daily increased count for different cases
    output$ChinaTS_inc <- renderPlot({
        ncov_tbl_country %>% 
            filter(`Country/Region` %in% c("China", "Taiwan*")) %>%
            filter(Case %in% c(input$TS_Case)) %>%
            ggplot() +
            geom_line(mapping = aes(x = Date, y = increment, color = Case), 
                      size = 2) +
            
            # Old method
            # scale_color_manual(values = c("red", "black", "green")) +
            
            # Assign color to the specific variable instead
            scale_color_manual(values = cl_case) +
            # get rid of scientific notation
            scale_y_continuous(labels = comma)+  #, format(total_count, scientific = F)) +
            labs(y = "Count") +
            theme_bw()+
            theme(text = element_text(size=20))+
            labs(title = "Time Series of Daily Increment")
    })
    
    output$table_CH <- DT::renderDataTable(DT::datatable({
        data <- ncov_ch_tbl[, c(1,5,6,7)]
        if (input$Date_T != "All") {
            data <- data[data$Date == input$Date_T,]
        }
        if (input$Province_T != "All") {
            data <- data[data$`Province/State` == input$Province_T,]
        }
        if (input$Case_T != "All") {
            data <- data[data$Case == input$Case_T,]
        }
        data
    }))
    
    
    ## The interactive world map:  ----------------------------
    # filter the data according to user selection
    filteredData <- reactive({
        ncov_tbl[ncov_tbl$Date == input$Date_w &
                     ncov_tbl$Case == input$Case_w, ]
    })
    
    cl_maker <- reactive(unname(cl_case[input$Case_w]))
    
    output$mymap <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(noWrap = TRUE))%>%
            setView(lng = 112.85, lat = 33.45, zoom = 4) #%>%
    })
    
    observe({
        # cl_maker <- unname(cl_case[input$Case_w])
        leafletProxy("mymap", data = filteredData()) %>%
            clearShapes() %>%
            addCircles(lat = ~Lat, lng = ~Long, radius = ~log(Count)*30000,
                       weight = 1, 
                       color = "red",fillColor = cl_maker(), fillOpacity = 0.7,
                       popup = ~paste(input$Case_w," number: ", Count, 
                                      " at ",
                                      ifelse(is.na(`Province/State`), "", `Province/State`),
                                      ' ', `Country/Region`)
                       # popup = ~paste(input$Case_type_w,
                       #                " ",input$Case_w," number: ", Count, 
                       #                " at ",
                       #                ifelse(is.na(`Province/State`), "", `Province/State`),
                       #                ' ', `Country/Region`)
            )
    })
    
    output$Barplot <- renderPlot({
        # date = Sys.Date() - days(1)
        ncov_tbl %>%
            filter(`Country/Region` %!in% c("China", "Taiwan*"), 
                   `Date` == input$Date_bp) %>%
            group_by(`Country/Region`) %>%
            filter(sum(Count) > input$range_bp[1] & sum(Count) < input$range_bp[2]) %>%
            # summarise(total_count = sum(Count)) %>%
            ggplot() +
            geom_col(mapping = aes(x = `Country/Region`, 
                                   y = `Count`, fill = `Case`)) + 
            # make the fill color consistent
            scale_fill_manual("", values = cl_case) +
            scale_y_continuous(labels = comma)+
            labs(title = input$Date_bp) + 
            # theme(text = element_text(size=20))+
            theme(axis.text.x = element_text(angle = 90), 
                  text = element_text(size=20))
    })
    
    # Text output for debuging and checking input class etc
    output$debugtext <- renderText({
        paste(input$range_bp[2],"and", input$range_bp[1])
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

