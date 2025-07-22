library(shiny)
library(shinydashboard)
library(leaflet)
library(httr)
library(jsonlite)
library(lubridate)
library(DT)
library(dplyr)
library(plotly)

api_key <- "YOUR API KEY"    #add your API KEY here

# UI
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(
    title = "Weather Forecast",
    titleWidth = 250
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Today's Weather", tabName = "current", icon = icon("cloud-sun")),
      menuItem("7-Day Forecast", tabName = "forecast", icon = icon("calendar-alt")),
      menuItem("24-Hour Forecast", tabName = "hourly", icon = icon("clock"))
    ),
    
    div(style = "padding: 15px;",
        h4("Search Location", style = "color: #fff; margin-bottom: 15px;"),
        textInput("city_search",
                  label = NULL,
                  placeholder = "Enter city name...",
                  value = ""),
        actionButton("search_btn", "Search",
                     icon = icon("search"),
                     class = "btn-primary btn-block",
                     style = "margin-top: 10px;")
    ),
    
    div(style = "padding: 15px; border-top: 1px solid #444;",
        h5("Current Location", style = "color: #fff;"),
        div(class = "map-container",
            div(class = "custom-spinner",
                leafletOutput("mini_map", height = "200px")
            )
        )
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background-color: #f0f8ff;
          color: #333;
        }
        .content-wrapper {
          background-color: #f0f8ff;
        }
        .skin-blue .main-header .navbar {
          background: linear-gradient(135deg, #3498db 0%, #5dade2 100%) !important;
        }
        .skin-blue .main-header .logo {
          background: linear-gradient(135deg, #3498db 0%, #5dade2 100%) !important;
        }
        .skin-blue .main-header .logo:hover {
          background: linear-gradient(135deg, #2980b9 0%, #4682b4 100%) !important;
        }
        .skin-blue .main-sidebar {
          background-color: #2c3e50 !important;
        }
        .skin-blue .sidebar-menu > li.active > a {
          background: linear-gradient(135deg, #3498db 0%, #5dade2 100%) !important;
        }
        .skin-blue .sidebar-menu > li:hover > a {
          background: linear-gradient(135deg, #2980b9 0%, #4682b4 100%) !important;
        }
        .weather-hero {
          background: linear-gradient(135deg, #3498db 0%, #5dade2 100%);
          color: white;
          border-radius: 15px;
          padding: 40px;
          margin-bottom: 25px;
          text-align: center;
          box-shadow: 0 10px 30px rgba(52, 152, 219, 0.3);
        }
        .weather-hero h1 {
          font-size: 48px;
          font-weight: 300;
          margin: 20px 0;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        .weather-hero .temp-display {
          display: flex;
          align-items: center;
          justify-content: center;
          margin: 30px 0;
        }
        .weather-hero .main-temp {
          font-size: 80px;
          font-weight: 100;
          margin: 0;
          line-height: 1;
        }
        .weather-hero .condition {
          font-size: 24px;
          opacity: 0.9;
          margin-bottom: 15px;
        }
        .weather-hero .high-low {
          font-size: 20px;
          opacity: 0.85;
          margin-top: 15px;
        }
        .highlights-section {
          background: white;
          border-radius: 15px;
          padding: 30px;
          margin-bottom: 25px;
          box-shadow: 0 5px 20px rgba(0,0,0,0.1);
          border-top: 4px solid #3498db;
        }
        .highlights-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
          gap: 20px;
        }
        .highlight-card {
          background: linear-gradient(135deg, #f0f8ff 0%, #d6eaf8 100%);
          border: 2px solid #a1c4fd;
          border-radius: 12px;
          padding: 20px;
          text-align: center;
          transition: all 0.3s ease;
        }
        .highlight-card:hover {
          transform: translateY(-5px);
          box-shadow: 0 8px 25px rgba(52,152,219,0.25);
          border-color: #3498db;
        }
        .highlight-card .icon {
          font-size: 28px;
          color: #3498db;
          margin-bottom: 10px;
        }
        .highlight-card .value {
          font-size: 24px;
          font-weight: 700;
          color: #2c3e50;
        }
        .highlight-card .label {
          font-size: 12px;
          color: #666;
          text-transform: uppercase;
        }
        .forecast-container {
          background: white;
          border-radius: 15px;
          padding: 30px;
          margin-bottom: 25px;
          box-shadow: 0 5px 20px rgba(0,0,0,0.1);
          border-top: 4px solid #3498db;
        }
        .forecast-header {
          font-size: 24px;
          font-weight: 700;
          color: #3498db;
          margin-bottom: 10px;
        }
        .forecast-location {
          font-size: 16px;
          color: #666;
          margin-bottom: 15px;
        }
        .daily-item {
          display: flex;
          align-items: center;
          padding: 15px;
          border-bottom: 1px solid #d6eaf8;
          transition: all 0.3s ease;
        }
        .daily-item:hover {
          background: linear-gradient(135deg, #f0f8ff 0%, #d6eaf8 100%);
          transform: translateX(5px);
        }
        .daily-date {
          flex: 1;
          font-weight: 700;
          font-size: 16px;
        }
        .daily-condition {
          flex: 2;
          font-size: 15px;
          color: #666;
        }
        .daily-temps {
          flex: 1;
          text-align: right;
          font-weight: 700;
        }
        .daily-high {
          color: #3498db;
        }
        .daily-low {
          color: #95a5a6;
          margin-left: 10px;
        }
        .daily-rain {
          flex: 1;
          text-align: center;
          font-size: 15px;
          color: #666;
        }
        .map-container {
          border-radius: 10px;
          overflow: hidden;
          box-shadow: 0 5px 20px rgba(0,0,0,0.1);
          position: relative;
        }
        .btn-primary {
          background: linear-gradient(135deg, #3498db 0%, #5dade2 100%);
          border: none;
          color: white;
          font-weight: 600;
          transition: all 0.3s ease;
        }
        .btn-primary:hover {
          background: linear-gradient(135deg, #2980b9 0%, #4682b4 100%);
          transform: translateY(-3px);
          box-shadow: 0 4px 15px rgba(52,152,219,0.4);
        }
        .loading-text {
          color: #3498db;
          font-style: italic;
          text-align: center;
          padding: 20px;
        }
        .custom-spinner {
          position: relative;
        }
        .custom-spinner.shiny-bound-output:empty::before {
          content: '';
          display: block;
          width: 40px;
          height: 40px;
          border: 4px solid #3498db;
          border-top: 4px solid transparent;
          border-radius: 50%;
          animation: spin 1s linear infinite;
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          z-index: 1000;
        }
        @keyframes spin {
          0% { transform: translate(-50%, -50%) rotate(0deg); }
          100% { transform: translate(-50%, -50%) rotate(360deg); }
        }
        .custom-spinner.shiny-bound-output:empty {
          opacity: 0.3;
          min-height: 40px;
        }
        .custom-spinner.shiny-bound-output:not(:empty) {
          opacity: 1;
        }
        .custom-spinner:hover::before {
          display: none;
        }
        @media (max-width: 768px) {
          .weather-hero .main-temp { font-size: 60px; }
          .weather-hero h1 { font-size: 36px; }
          .highlights-grid { grid-template-columns: repeat(2, 1fr); }
        }
      "))
    ),
    
    tabItems(
      tabItem(tabName = "current",
              fluidRow(
                column(width = 12,
                       div(class = "weather-hero",
                           div(class = "custom-spinner shiny-bound-output",
                               uiOutput("city_name")
                           ),
                           div(class = "temp-display",
                               div(class = "main-temp", div(class = "custom-spinner shiny-bound-output", textOutput("current_temp")))
                           ),
                           div(class = "condition", div(class = "custom-spinner shiny-bound-output", textOutput("condition_value"))),
                           div(class = "high-low", div(class = "custom-spinner shiny-bound-output", textOutput("high_low_temp")))
                       )
                )
              ),
              fluidRow(
                column(width = 12,
                       div(class = "highlights-section",
                           div(class = "forecast-header", "Today's Highlights"),
                           div(class = "highlights-grid",
                               div(class = "highlight-card",
                                   div(class = "icon", icon("tint")),
                                   div(class = "value", div(class = "custom-spinner shiny-bound-output", textOutput("humidity_value"))),
                                   div(class = "label", "Humidity")
                               ),
                               div(class = "highlight-card",
                                   div(class = "icon", icon("wind")),
                                   div(class = "value", div(class = "custom-spinner shiny-bound-output", textOutput("wind_speed_value"))),
                                   div(class = "label", "Wind Speed")
                               ),
                               div(class = "highlight-card",
                                   div(class = "icon", icon("cloud-rain")),
                                   div(class = "value", div(class = "custom-spinner shiny-bound-output", textOutput("rain_prob_value"))),
                                   div(class = "label", "Rain Probability")
                               )
                           )
                       )
                )
              )
      ),
      
      tabItem(tabName = "forecast",
              fluidRow(
                column(width = 12,
                       div(class = "forecast-container",
                           div(class = "forecast-header", "7-Day Weather Forecast"),
                           div(class = "forecast-location", textOutput("forecast_location")),
                           div(class = "daily-forecast",
                               div(class = "custom-spinner shiny-bound-output", uiOutput("daily_forecast"))
                           )
                       )
                )
              )
      ),
      
      tabItem(tabName = "hourly",
              fluidRow(
                column(width = 12,
                       div(class = "forecast-container",
                           div(class = "forecast-header", "24-Hour Forecast"),
                           div(class = "forecast-location", textOutput("hourly_location")),
                           selectInput("selected_day", "Select Day:", choices = NULL),
                           div(class = "custom-spinner shiny-bound-output",
                               plotlyOutput("hourly_chart", height = "400px")
                           )
                       )
                )
              )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  safe_api_call <- function(url, description = "API call", timeout_seconds = 15) {
    tryCatch({
      response <- GET(url, timeout(timeout_seconds))
      if (status_code(response) != 200) {
        showNotification(paste("API Error:", description, "- Status:", status_code(response)), 
                         type = "error", duration = 5)
        return(NULL)
      }
      content_text <- content(response, "text", encoding = "UTF-8")
      if (is.null(content_text) || nchar(content_text) == 0) {
        showNotification(paste("Empty response from", description), type = "warning", duration = 3)
        return(NULL)
      }
      data <- fromJSON(content_text, flatten = TRUE, simplifyVector = FALSE)
      if (is.atomic(data) && !is.list(data)) {
        showNotification(paste("Invalid data format from", description), type = "warning", duration = 3)
        return(NULL)
      }
      return(data)
    }, error = function(e) {
      showNotification(paste("Network error:", e$message), type = "error", duration = 5)
      return(NULL)
    })
  }
  
  safe_get <- function(data, path, default = NULL) {
    if (is.null(data)) return(default)
    tryCatch({
      result <- data
      for (key in path) {
        if (is.list(result) && key %in% names(result)) {
          result <- result[[key]]
        } else if (is.list(result) && is.numeric(key) && key <= length(result)) {
          result <- result[[key]]
        } else {
          return(default)
        }
      }
      if (is.null(result) || (is.atomic(result) && length(result) == 0)) {
        return(default)
      }
      return(result)
    }, error = function(e) {
      return(default)
    })
  }
  
  update_location <- function() {
    req(rv$lat, rv$lon)
    current_url <- paste0("https://api.openweathermap.org/data/2.5/weather?lat=",
                          rv$lat, "&lon=", rv$lon, "&units=metric&appid=", api_key)
    data <- safe_api_call(current_url, "location update")
    if (!is.null(data)) {
      city_name <- safe_get(data, "name", "Unknown")
      country_code <- safe_get(data, c("sys", "country"), "XX")
      if (!is.null(city_name) && !is.null(country_code)) {
        rv$city <- paste0(city_name, ", ", country_code)
        showNotification("Location updated successfully!", type = "message", duration = 3)
      }
    }
  }
  
  rv <- reactiveValues(
    lat = 20.6461,
    lon = 106.0570,
    city = "Hung Yen, VN"
  )
  
  observeEvent(input$mini_map_click, {
    req(input$mini_map_click)
    click <- input$mini_map_click
    if (!is.null(click$lat) && !is.null(click$lng)) {
      rv$lat <- click$lat
      rv$lon <- click$lng
      update_location()
    }
  })
  
  observeEvent(input$search_btn, {
    req(input$city_search)
    city_query <- trimws(input$city_search)
    if (nchar(city_query) > 0) {
      showNotification("Searching for location...", type = "message", duration = 2)
      geocoding_url <- paste0("http://api.openweathermap.org/geo/1.0/direct?q=",
                              URLencode(city_query), "&limit=1&appid=", api_key)
      geocoding_data <- safe_api_call(geocoding_url, "geocoding search")
      if (!is.null(geocoding_data) && length(geocoding_data) > 0) {
        first_result <- geocoding_data[[1]]
        new_lat <- safe_get(first_result, "lat", NULL)
        new_lon <- safe_get(first_result, "lon", NULL)
        city_name <- safe_get(first_result, "name", NULL)
        country_code <- safe_get(first_result, "country", NULL)
        if (!is.null(new_lat) && !is.null(new_lon) && !is.null(city_name) && !is.null(country_code)) {
          rv$lat <- as.numeric(new_lat)
          rv$lon <- as.numeric(new_lon)
          rv$city <- paste0(city_name, ", ", country_code)
          updateTextInput(session, "city_search", value = "")
          showNotification(paste("Found:", rv$city), type = "message", duration = 3)
        } else {
          showNotification("Invalid location data received", type = "warning", duration = 5)
        }
      } else {
        showNotification("City not found. Please try a different search term.", type = "warning", duration = 5)
      }
    }
  })
  
  current_data <- reactive({
    req(rv$lat, rv$lon)
    current_url <- paste0("https://api.openweathermap.org/data/2.5/weather?lat=",
                          rv$lat, "&lon=", rv$lon, "&units=metric&appid=", api_key)
    data <- safe_api_call(current_url, "current weather")
    return(data)
  })
  
  forecast_data <- reactive({
    req(rv$lat, rv$lon)
    forecast_url <- paste0("https://api.openweathermap.org/data/2.5/forecast?lat=",
                           rv$lat, "&lon=", rv$lon, "&units=metric&appid=", api_key)
    data <- safe_api_call(forecast_url, "weather forecast")
    return(data)
  })
  
  output$mini_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = rv$lon, lat = rv$lat, zoom = 8) %>%
      addMarkers(lng = rv$lon, lat = rv$lat, popup = rv$city)
  })
  
  observe({
    req(rv$lat, rv$lon, rv$city)
    leafletProxy("mini_map") %>%
      clearMarkers() %>%
      setView(lng = rv$lon, lat = rv$lat, zoom = 8) %>%
      addMarkers(lng = rv$lon, lat = rv$lat, popup = rv$city)
  })
  
  output$city_name <- renderUI({
    req(rv$city)
    h1(rv$city, style = "font-weight: 400; margin: 0;")
  })
  
  output$current_temp <- renderText({
    data <- current_data()
    temp <- safe_get(data, c("main", "temp"), NULL)
    if (!is.null(temp)) {
      paste0(round(as.numeric(temp), 0), "°C")
    } else {
      "Loading..."
    }
  })
  
  output$condition_value <- renderText({
    data <- current_data()
    if (!is.null(data)) {
      weather_list <- safe_get(data, "weather", NULL)
      if (!is.null(weather_list) && length(weather_list) > 0) {
        first_weather <- weather_list[[1]]
        description <- safe_get(first_weather, "description", "Loading...")
        tools::toTitleCase(as.character(description))
      } else {
        "Loading..."
      }
    } else {
      "Loading..."
    }
  })
  
  output$high_low_temp <- renderText({
    data <- current_data()
    temp_min <- safe_get(data, c("main", "temp_min"), NULL)
    temp_max <- safe_get(data, c("main", "temp_max"), NULL)
    if (!is.null(temp_min) && !is.null(temp_max)) {
      paste0("High: ", round(as.numeric(temp_max), 0), "°C | Low: ", round(as.numeric(temp_min), 0), "°C")
    } else {
      "Loading..."
    }
  })
  
  output$humidity_value <- renderText({
    data <- current_data()
    humidity <- safe_get(data, c("main", "humidity"), NULL)
    if (!is.null(humidity)) {
      paste0(humidity, "%")
    } else {
      "Loading..."
    }
  })
  
  output$wind_speed_value <- renderText({
    data <- current_data()
    wind_speed <- safe_get(data, c("wind", "speed"), NULL)
    if (!is.null(wind_speed)) {
      paste0(round(as.numeric(wind_speed) * 3.6, 1), " km/h")
    } else {
      "Loading..."
    }
  })
  
  output$rain_prob_value <- renderText({
    data <- forecast_data()
    forecast_list <- safe_get(data, "list", NULL)
    if (!is.null(forecast_list) && length(forecast_list) > 0) {
      current_date <- as.Date(Sys.Date())
      for (item in forecast_list) {
        dt_txt <- safe_get(item, "dt_txt", "")
        if (nchar(dt_txt) > 0 && as.Date(dt_txt) == current_date) {
          pop <- safe_get(item, "pop", 0)
          return(paste0(round(as.numeric(pop) * 100, 0), "%"))
        }
      }
      return("0%")
    } else {
      "Loading..."
    }
  })
  
  output$forecast_location <- renderText({
    req(rv$city)
    paste("Location:", rv$city)
  })
  
  output$hourly_location <- renderText({
    req(rv$city)
    paste("Location:", rv$city)
  })
  
  output$daily_forecast <- renderUI({
    data <- forecast_data()
    forecast_list <- safe_get(data, "list", NULL)
    if (!is.null(forecast_list) && length(forecast_list) > 0) {
      tryCatch({
        daily_data <- data.frame(
          DateTime = character(),
          Date = character(),
          Temp_Min = numeric(),
          Temp_Max = numeric(),
          Condition = character(),
          Rain_Prob = numeric(),
          stringsAsFactors = FALSE
        )
        for (i in 1:length(forecast_list)) {
          item <- forecast_list[[i]]
          dt_txt <- safe_get(item, "dt_txt", "")
          if (nchar(dt_txt) > 0) {
            date_part <- as.Date(substr(dt_txt, 1, 10))
            temp_min <- as.numeric(safe_get(item, c("main", "temp_min"), 0))
            temp_max <- as.numeric(safe_get(item, c("main", "temp_max"), 0))
            pop <- as.numeric(safe_get(item, "pop", 0)) * 100
            weather_list <- safe_get(item, "weather", NULL)
            if (!is.null(weather_list) && length(weather_list) > 0) {
              first_weather <- weather_list[[1]]
              condition <- safe_get(first_weather, "main", "Clear")
            } else {
              condition <- "Clear"
            }
            daily_data <- rbind(daily_data, data.frame(
              DateTime = dt_txt,
              Date = as.character(date_part),
              Temp_Min = temp_min,
              Temp_Max = temp_max,
              Condition = condition,
              Rain_Prob = pop,
              stringsAsFactors = FALSE
            ))
          }
        }
        if (nrow(daily_data) > 0) {
          daily_data$Date <- as.Date(daily_data$Date)
          daily_summary <- daily_data %>%
            group_by(Date) %>%
            summarize(
              Min_Temp = round(min(Temp_Min, na.rm = TRUE), 0),
              Max_Temp = round(max(Temp_Max, na.rm = TRUE), 0),
              Main_Condition = {
                condition_table <- table(Condition)
                names(condition_table)[which.max(condition_table)]
              },
              Rain_Prob = round(mean(Rain_Prob, na.rm = TRUE), 0),
              .groups = 'drop'
            )
          daily_count <- min(nrow(daily_summary), 7)
          daily_divs <- lapply(1:daily_count, function(i) {
            row <- daily_summary[i, ]
            current_date <- as.Date(Sys.Date())
            Sys.setlocale("LC_TIME", "en_US.UTF-8")
            if (row$Date == current_date) {
              date_str <- paste0(format(row$Date, "%A"), " (Today)")
            } else if (row$Date == current_date + 1) {
              date_str <- paste0(format(row$Date, "%A"), " (Tomorrow)")
            } else {
              date_str <- format(row$Date, "%A, %b %d")
            }
            div(class = "daily-item",
                div(class = "daily-date", date_str),
                div(class = "daily-condition", row$Main_Condition),
                div(class = "daily-rain", paste0(row$Rain_Prob, "%")),
                div(class = "daily-temps",
                    span(class = "daily-high", paste0(row$Max_Temp, "°C")),
                    span(class = "daily-low", paste0(row$Min_Temp, "°C"))
                )
            )
          })
          return(daily_divs)
        } else {
          return(div(class = "loading-text", "No forecast data available"))
        }
      }, error = function(e) {
        return(div(class = "loading-text", paste("Error loading forecast:", e$message)))
      })
    } else {
      return(div(class = "loading-text", "Loading daily forecast..."))
    }
  })
  
  observe({
    data <- forecast_data()
    forecast_list <- safe_get(data, "list", NULL)
    if (!is.null(forecast_list) && length(forecast_list) > 0) {
      Sys.setlocale("LC_TIME", "en_US.UTF-8")
      dates <- unique(as.Date(sapply(forecast_list, function(x) substr(safe_get(x, "dt_txt", ""), 1, 10))))
      dates <- dates[1:min(length(dates), 7)]
      date_choices <- setNames(as.character(dates), 
                               sapply(1:length(dates), function(i) {
                                 current_date <- as.Date(Sys.Date())
                                 if (dates[i] == current_date) {
                                   paste0(format(dates[i], "%A"), " (Today)")
                                 } else if (dates[i] == current_date + 1) {
                                   paste0(format(dates[i], "%A"), " (Tomorrow)")
                                 } else {
                                   format(dates[i], "%A, %b %d")
                                 }
                               }))
      updateSelectInput(session, "selected_day", choices = date_choices, selected = date_choices[1])
    }
  })
  
  output$hourly_chart <- renderPlotly({
    data <- forecast_data()
    forecast_list <- safe_get(data, "list", NULL)
    selected_date <- input$selected_day
    if (!is.null(forecast_list) && length(forecast_list) > 0 && !is.null(selected_date)) {
      hourly_data <- data.frame(
        Time = character(),
        Temp = numeric(),
        Rain_Prob = numeric(),
        Humidity = numeric(),
        stringsAsFactors = FALSE
      )
      for (item in forecast_list) {
        dt_txt <- safe_get(item, "dt_txt", "")
        if (nchar(dt_txt) > 0 && substr(dt_txt, 1, 10) == selected_date) {
          time_str <- format(as.POSIXct(dt_txt), "%H:%M")
          temp <- as.numeric(safe_get(item, c("main", "temp"), 0))
          pop <- as.numeric(safe_get(item, "pop", 0)) * 100
          humidity <- as.numeric(safe_get(item, c("main", "humidity"), 0))
          hourly_data <- rbind(hourly_data, data.frame(
            Time = time_str,
            Temp = temp,
            Rain_Prob = pop,
            Humidity = humidity,
            stringsAsFactors = FALSE
          ))
        }
      }
      if (nrow(hourly_data) > 0) {
        plot_ly(hourly_data) %>%
          add_lines(x = ~Time, y = ~Temp, name = "Temperature (°C)", line = list(color = "#3498db")) %>%
          add_lines(x = ~Time, y = ~Rain_Prob, name = "Rain Probability (%)", yaxis = "y2", 
                    line = list(color = "#95a5a6", dash = "dash")) %>%
          add_lines(x = ~Time, y = ~Humidity, name = "Humidity (%)", yaxis = "y2", 
                    line = list(color = "#2ecc71", dash = "dot")) %>%
          layout(
            xaxis = list(title = "Time"),
            yaxis = list(title = "Temperature (°C)", color = "#3498db"),
            yaxis2 = list(title = "Rain Probability / Humidity (%)", overlaying = "y", side = "right", 
                          color = "#95a5a6"),
            showlegend = TRUE,
            legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 1.1),
            margin = list(r = 50, t = 50)
          )
      } else {
        plot_ly() %>% 
          add_text(text = "No data available for selected day", x = 0.5, y = 0.5, showlegend = FALSE)
      }
    } else {
      plot_ly() %>% 
        add_text(text = "Loading data...", x = 0.5, y = 0.5, showlegend = FALSE)
    }
  })
  
  observeEvent(session$clientData, {
    Sys.sleep(0.5)
    update_location()
  }, once = TRUE)
}

# Chạy ứng dụng
shinyApp(ui = ui, server = server)