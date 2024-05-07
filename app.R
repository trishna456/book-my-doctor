#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Load necessary libraries
#install.packages("ggplot2", dependencies=TRUE)
#install.packages("RMySQL")
#install.packages("ggplot2")
#install.packages("tidyr")
library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinyjs)
library(RMySQL)
library(DBI)
library(RColorBrewer)
library(plotly)
library(leaflet)
library(tidyr)
library(DT)
library(tidygeocoder)
library(shinyWidgets)


# UI for Login/ Create Account Page
login_ui <- fluidPage(
  
  titlePanel("" , windowTitle = "BookMyDoc"),
  
  # Assign Theme
  theme = shinytheme("sandstone"),
  
  # Load CSS
  includeCSS("customize.css"),
  useShinyjs(),
  
  setBackgroundImage(
    src = "background.jpg",
    shinydashboard = FALSE
  ),
  
  fluidRow(  
    br(),
    tags$h1("BookMyDoc", align = "center"),
    tags$h4("A Medical Appointment Booking Platform", align = "center"),
    br(),
    br()
  ),
  fluidRow(
    column(
      4,
      offset = 4,
      
      # Log In form
      div(id = "login_div",
          wellPanel(
            h3("Log In to your Account"),
            br(),
            textInput("email", "Email"),
            passwordInput("password", "Password"),
            br(),
            actionButton("login", "Log in"),
            actionButton("signup", "Sign Up")
          )
      ),
      
      # Sign Up Form
      div(id = "signup_div", style = "display:none",
          wellPanel(
            h3("Create Account"),
            br(),
            textInput("fname", "First Name"),
            textInput("lname", "Last Name"),
            radioButtons("gender", "Gender", choices = c("Female", "Male")),
            textInput("new_email", "Email"),
            passwordInput("pwd", "Password"),
            passwordInput("confirmpwd", "Confirm Password"),
            br(),
            actionButton("submit", "Sign Up")
          )
      )
    )
  )
)


# UI for Main/ Dashboard Page
main_ui <- fluidPage(
  
  titlePanel("", windowTitle = "BookMyDoc"),
  
  # Assign Theme
  theme = shinytheme("sandstone"),
  
  # Load CSS
  includeCSS("customize.css"),
  tags$h1("BookMyDoc", align = "center"),
  tags$h4("A Medical Appointment Booking Platform", align = "center"),
  
  # Dashboard Content
  dashboardPage(
    
    # Dashboard Header
    dashboardHeader(
      
      # Display the Name of the logged in user
      title = tags$h4(textOutput("user_name"), style = "color: white;"),
      
      # Drop down for Log Out and Appointments Page
      dropdownMenu(type = "tasks", icon = icon("user"),
                   badgeStatus = NULL,
                   headerText = "",
                   menuSubItem(actionButton("appointments", "Appointments", class = "btn-success"), icon = icon("info-circle")),
                   menuSubItem(actionButton("logout", "Logout", class = "btn-danger"), icon = icon("sign-out-alt"))
      )
    ),
    
    # Dashboard Sidebar for input filters
    dashboardSidebar(
      
      sidebarMenu(
        
        # Filter for Specialty
        menuItem("Specialties", tabName = "selector", icon = icon("list"),
                 uiOutput("select_specialties"),
                 tags$head(
                   tags$style(HTML("Select Specialty {color: black;};"))
                 )
        ),
        
        # Filter for Experience
        menuItem("Experience", tabName = "slider", icon = icon("sliders-h"),
                 sliderInput("experience", "Select a value:", min = 0, max = 40, value = 0),
                 tags$head(
                   tags$style(HTML(".sliderlabel {color: black;};"))
                 )
        ),
        
        # Filter for Services
        menuItem("Services", tabName = "checkbox", icon = icon("check-square"),
                 checkboxInput("checkbox_teleconsultation", "Teleconsultation", value = FALSE),
                 checkboxInput("checkbox_individual", "Individual Medicare", value = FALSE),
                 checkboxInput("checkbox_group", "Group Medicare", value = FALSE)
                 #tags$head(
                 #  tags$style(HTML(".checkbox label {color: black;};"))
                 #)
        )
        #actionButton("filter", "Filter Results")
      )
    ),
    
    # Dashboard Body
    dashboardBody(
      
      # Tabs for different pages
      tabsetPanel(
        id = "tabs",
        
        # Landing Tab where visualizations are displayed
        tabPanel("Dashboard", 
                 
                 br(),
                 fluidRow(
                   
                   # Box displaying Number of Doctors
                   box(
                     title = tags$h1(textOutput("num_doctors"), align = "center"), 
                     width = 4, 
                     background = "green",
                     tags$h3("Doctors & Clinicians", align = "center")
                   ),
                   
                   # Box displaying Number of Patients
                   box(
                     title = tags$h1(textOutput("num_patients"), align = "center"), 
                     width = 4, 
                     background = "yellow",
                     tags$h3("Patients Served", align = "center")
                   ),
                   
                   # Box displaying Number of Hospitals/ Organizations
                   box(
                     title = tags$h1(textOutput("num_orgs"), align = "center"), 
                     width = 4, 
                     background = "green",
                     tags$h3("Hospitals & Organizations", align = "center")
                   )
                 ),
                 
                 fluidRow(
                   # Box displaying Bar Chart of Doctors by their education degree
                   box(title = "Frequency of Doctors based on their Education Level", 
                       status = "success",
                       plotlyOutput("credentialbar")),
                   box(title = "Experience V/s Number of Specialties", 
                       status = "warning",
                       plotlyOutput("specialtiesboxplot"))
                 ),
                 
                 fluidRow(
                   # Box displaying Box Plot of Number of Specialties
                   box(title = "Statistics of Different Specialties", 
                       status = "success", solidHeader = TRUE,
                       collapsible = TRUE,
                       background = "green",
                       plotlyOutput("statstable"), width = 12)
                 ),
                 
                 fluidRow(
                   # Box displaying Pie Chart of Gender
                   box(title = "Distribution of Gender", 
                       status = "warning",
                       plotlyOutput("genderpie")),
                   
                   # Box displaying Map with locations of Doctors
                   box(title = "Doctor Locations", 
                       status = "success",
                       leafletOutput("map"), 
                       width = 6)
                 )
        ),
        
        # Tab for displaying Doctor's information and booking appointment
        tabPanel("Doctors", 
                 br(),
                 DTOutput("doctors_table"),
                 uiOutput("details_ui")
        ),
        
        # Tab for displaying Appointment information and modifying/deleting the appointment
        tabPanel("Appointments", 
                 br(),
                 tags$h2("Your upcoming appointments", align = "center"),
                 DTOutput("appointments_table"),
                 uiOutput("appointment_ui")
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Initialize logged in state
  logged_in <- reactiveVal(FALSE)
  
  # Main Page logic
  output$main_content <- renderUI({
    
    con <<- dbConnect(MySQL(), user = "root", password = "root1234", dbname = "doctors_appointment_db", host = "34.170.21.186")
    
    # Condition to show UI
    if (logged_in()) {
      main_ui
    } else {
      login_ui
    }
  })
  
  # Toggle between Log In and Sign Up content
  observeEvent(input$signup, {
    shinyjs::hide("login_div")
    shinyjs::show("signup_div")
  })
  
  # Sign Up Functionality
  
  # Logic when Sign Up button is clicked
  observeEvent(input$submit, {
    
    if(input$fname == "" | input$lname == "" | input$gender == "" | input$new_email == "" | input$pwd == ""){
      # Show message if any value is blank
      showModal(modalDialog(
        title = "Please enter all values in the form",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    
    else{
      if(check_email(input$new_email) != 0){
        # Show message when email is already used
        showModal(modalDialog(
          title = "Account already exists.",
          paste0("This email is already in use."),
          easyClose = TRUE,
          footer = NULL
        ))
      }
      
      else{
        if(input$pwd != input$confirmpwd){
          # Show message when passwords don't match
          showModal(modalDialog(
            title = "Passwords do not match",
            paste0("Please enter same password in confirm password"),
            easyClose = TRUE,
            footer = NULL
          ))
        }
        else{
          if(insert_patient(input$fname, input$lname, input$gender, input$new_email, input$pwd) > 0){
            # Show message when account is created
            showModal(modalDialog(
              title = "Account Created Successfully",
              paste0("Please Log In to View Doctors and Book Appointment"),
              easyClose = TRUE,
              footer = NULL
            ))
            # Toggle to Log In form
            shinyjs::hide("signup_div")
            shinyjs::show("login_div")
          }
          
          # Show message when there is any error in account creation
          else{
            showModal(modalDialog(
              title = "Something went wrong",
              paste0("Sorry! Please try again."),
              easyClose = TRUE,
              footer = NULL
            ))
          }
        }
      }
    }
  })
  
  # Function to check if email is present in DB
  # Parameters: Email
  # Returns: Count of rows in DB
  check_email <- function(new_email){
    result <- dbGetQuery(con, paste0("SELECT COUNT(*) AS Count FROM PATIENTS WHERE Email = '",new_email,"'"))
    return(result$Count)
  }
  
  # Function to check insert in Patients table for account creation
  # Parameters: First Name, Last Name, Gender, Email, Password
  # Returns: Status of query execution
  insert_patient <- function(first_name, last_name, gender, email, password){
    if(gender == "Male"){
      gender_char <- 'M'
    }
    else{
      gender_char <- 'F'
    }
    query <- paste0("INSERT INTO Patients(FirstName, LastName, Gender, Email, Pwd) VALUES ('",first_name,"','",last_name,"','",gender_char,"','",email,"',SHA2('",password,"',256))")
    return(dbExecute(con, query))
  }
  
  # Log In Functionality
  
  # Function to check is user exists in DB
  # Parameters: Email, Password
  # Returns: Boolean value depending on account is present in the DB
  authenticate_user <- function(email, password) {
    result <- dbGetQuery(con, paste("SELECT * FROM Patients WHERE Email = '", email, "' AND Pwd = SHA2('", password, "',256)", sep = ""))
    if (nrow(result) == 1) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  # Login button logic
  observeEvent(input$login, {
    
    # Check username and password
    if (authenticate_user(input$email, input$password)) {
      logged_in(TRUE)
      patient_id <<- get_patient(input$email)$PatientID
    } else {
      
      # Show error message if Log In failed
      showModal(modalDialog(
        title = "Login failed",
        "Invalid username or password. Please try again.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  # Get name of the logged in user
  output$user_name <- renderText({
    if(logged_in() == TRUE){
      get_patient(input$email)$PatientName
    }
  })
  
  
  # Dashboard Sidebar Functionality
  
  # Function to get Patient name from DB
  # Parameters: Email, Password
  # Returns: Patient Name and ID
  get_patient <- function(email, password) {
    result <- dbGetQuery(con, paste("SELECT PatientID, CONCAT(FirstName, ' ', LastName) AS PatientName FROM Patients WHERE Email = '", email, "'", sep = ""))
    return(result)
  }
  
  # List all Specialties in the Input dropdown
  output$select_specialties <- renderUI({
    specialties <- get_all_specialties()
    selectInput("select_specialty", "Select Specialty:", choices = specialties, selected = "VIEW ALL")
  })
  
  # Function to get Specialty Names
  # Returns: Specialty Names
  get_all_specialties <- function(){
    result <- dbGetQuery(con, "SELECT DISTINCT SpecialtyName FROM Specialties")
    specialties <- result$SpecialtyName
    specialties<- c(specialties, "VIEW ALL")
    return(result$SpecialtyName)
  }
  
  
  # Dashboard Tab Functionality
  
  
  # Get No. of Doctors
  output$num_doctors <- renderText({
    result <- dbGetQuery(con, "SELECT COUNT(DISTINCT DoctorID) AS Count FROM Doctors")
    result$Count
  })
  
  # Get No. of Patients
  output$num_patients <- renderText({
    result <- dbGetQuery(con, "SELECT COUNT(*)  AS Count FROM Patients")
    result$Count
  })
  
  # Get No. of Hospitals
  output$num_orgs <- renderText({
    result <- dbGetQuery(con, "SELECT COUNT(*)  AS Count FROM Organizations")
    result$Count
  })
  
  # Function to get Doctor's Education Degree for plotting in Bar Graph
  # Returns: dataframe of containing count of each credential
  get_credentials <-function(){
    credentials_df <- dbGetQuery(con, paste0("SELECT Credential, COUNT(*) AS Num_Of_Doctors 
                                    FROM doctor_details 
                                    WHERE Credential != ''",get_conditions(),"
                                    GROUP BY Credential LIMIT 10"))
    return(credentials_df)
  }
  
  # Plot Bar Graph of Doctor's credentials
  output$credentialbar <- renderPlotly({
    plot_ly(get_credentials(), x = ~Credential, y = ~Num_Of_Doctors, type = 'bar', marker = list(color = brewer.pal(length(get_credentials()$Credential), "Set3"))) %>%
      layout(xaxis = list(title = 'Credential'), yaxis = list(type = 'log', title = 'No. of Doctors'))
  })
  
  
  # Function to get Doctor's experience based on no. of specialties Doctors holds
  # Returns: dataframe of counts and years of experience of Doctors having a specialty count
  get_box_data <- function(){
    box_df <- dbGetQuery(con, "SELECT DoctorID, COUNT(DISTINCT SpecialtyID) AS Num_Specialties, Experience
                                  FROM doctors_experience
                                  GROUP BY DoctorID, Experience
                                  ORDER BY Num_Specialties DESC")
    return(box_df)
  }
  
  # Plot Box Plot of specialty wise experience
  output$specialtiesboxplot <- renderPlotly({
    specialties_df <- get_box_data()
    specialties_df <- specialties_df %>% 
      mutate(Specialties = ifelse(Num_Specialties == 1, "1",
                                  ifelse(Num_Specialties == 2, "2",
                                         ifelse(Num_Specialties == 3,"3","4"))))
    
    plot_ly(data = specialties_df, x = ~Specialties, y = ~Experience, type = "box", color=~Specialties) %>% 
      layout(xaxis = list(title = 'No. of Specialties'), yaxis = list(title = 'Experience in Years'))
  })
  
  # Function to get Doctor's coordinates
  # Returns: Dataframe containing coordinates
  get_coordinates <- function(){
    address_df <- dbGetQuery(con, paste0("SELECT * FROM doctors_appointment_db.coordinates_temp
                                          WHERE DoctorID IN (SELECT DISTINCT(DoctorID)
					                                FROM doctor_details WHERE DoctorId != ''",get_conditions(),")"))
    return(address_df)
  }
  
  # Plot Map or locations of Doctors
  output$map <- renderLeaflet({
    leaflet(get_coordinates()) %>%
      addTiles() %>%
      addMarkers(label = ~DoctorName, popup = ~DoctorName, clusterOptions = markerClusterOptions())
  })
  
  
  # Function to get statistics of each specialty from doctors_experience view
  # Returns: dataframe with statistics
  get_statistics <- function(){
    stats_df <- dbGetQuery(con, "SELECT s.SpecialtyName, 
                              	COUNT(de.DoctorID) AS Num_of_Doctors, 
                              	CAST(AVG(de.Experience) AS UNSIGNED) AS Avg_Experience, 
                                  MIN(de.Experience) AS Min_Experience, 
                                  MAX(de.Experience) AS Max_Experience 
                              FROM doctors_experience de
                              JOIN Specialties s
                              USING (SpecialtyID)
                              GROUP BY SpecialtyName
                              ORDER BY Num_Of_Doctors DESC
                              ")
    return(stats_df)
  }
  
  # Plot Statitics table
  output$statstable <- renderPlotly({
    plot_ly(
      get_statistics(),
      type = "table",
      header = list(values = colnames(get_statistics())),
      cells = list(values = t(get_statistics()))
    )
  })
  
  # Function to get gender counts of Doctors
  # Returns: dataframe with gender counts
  get_genders <- function(){
    gender_df <- dbGetQuery(con, paste0("SELECT Gender, COUNT(*) AS Count 
                                        FROM doctor_details
                                        WHERE DoctorID != ''" ,get_conditions(),"
                                        GROUP BY Gender"))
    return(gender_df)
  }
  
  # Plot Pie Chart of Gender counts
  output$genderpie <- renderPlotly({
    plot_ly(get_genders(), labels = ~Gender, values = ~Count, type = "pie")
  })
  
  # Doctors Tab Functionality
  
  # Function to get conditions in SQL query based on filters applied
  # Returns: Query string with conditions
  get_conditions <- function(){
    
    specialty_condition = ""
    grad_condition = ""
    teleconsultation_condition = ""
    individual_condition = ""
    group_condition = ""
    
    # Form a query string for Specialty filter
    specialty_filter <- input$select_specialty
    if(length(specialty_filter) != 0){
      if(specialty_filter != 'VIEW ALL'){
        specialty_condition = paste0(" AND SpecialtyName = '", specialty_filter,"'")
      }
    }
    
    # Form a query string for Doctor's Experience
    experience_filter <- input$experience
    if(experience_filter != 0){
      grad_year = as.numeric(format(Sys.Date(), "%Y")) - experience_filter
      grad_condition = paste0(" AND GraduationYear = '", grad_year,"'")
    }
    
    # Form a query string for Services filter
    teleconsultation_filter <- input$checkbox_teleconsultation
    if(teleconsultation_filter){
      teleconsultation_condition = " AND Teleconsultation = 'Y'"
    }
    
    individual_filter <- input$checkbox_individual
    if(individual_filter){
      individual_condition = " AND IndividualMedicare = 'Y'"
    }
    
    group_filter <- input$checkbox_group
    if(group_filter){
      group_condition = " AND GroupMedicare = 'Y'"
    }
    
    # Concat all query string for all filters
    conditional_query <- paste0(specialty_condition, grad_condition, teleconsultation_condition, individual_condition, group_condition)
    return(conditional_query)
  }
  
  # Function to get Doctor details from DB
  # Parameters: Doctor ID
  # Returns: dataframe with Doctor details
  get_doctors <- function(doctor_id){
    if(doctor_id == 0){
      query <- paste0("SELECT DISTINCT(DoctorID), DoctorName, SpecialtyName, Credential, GraduationYear, Teleconsultation
                               FROM doctor_details WHERE DoctorID != ''", get_conditions())
      doctors_df <- dbGetQuery(con, query)
    }
    else{
      doctors_df <- dbGetQuery(con, paste0("SELECT DISTINCT(DoctorID), DoctorName, Gender, SpecialtyName, SchoolName, Credential, GraduationYear, Teleconsultation, IndividualMedicare, GroupMedicare, PhoneNumber
                                           FROM doctor_details
                                           WHERE DoctorID = '", doctor_id, "'"))
    }
    #doctors_df$Appoitnments <- rep('View & Book', 10)
    return(doctors_df)
  }
  
  # Function to get Doctor's address
  # Parameters: Doctor ID
  # Returns: String of Address
  get_doctor_address <- function(doctor_id){
    
    address <- dbGetQuery(con, paste0("SELECT CONCAT(AddressLine1, ', ', City, ', ', State) AS Address
                                      FROM Addresses 
                                      WHERE AddressID = (SELECT 
                            					CASE 
                            						WHEN (SELECT COUNT(*) FROM DoctorClinics WHERE DoctorID = '", doctor_id, "') > 0 
                                                    THEN (SELECT DISTINCT AddressID
                            							FROM DoctorClinics
                            							WHERE DoctorID = '", doctor_id, "')
                            						ELSE (SELECT DISTINCT o.AddressID
                            							FROM DoctorOrganizations dorg
                            							JOIN Organizations o USING(OrganizationID)
                            							WHERE dorg.DoctorID = '", doctor_id, "')
                            					END AS AddressID)"))
    return(address$Address)
  }
  
  # Function to get Doctor's Organization Name
  # Parameters: Doctor ID
  # Returns: dataframe with Organization Name and isHospital boolean variable
  get_doctor_org <- function(doctor_id){
    
    org_df <- dbGetQuery(con, paste0("SELECT org.OrganizationName, dorg.isHospital
                                      FROM Organizations org
                                      JOIN DoctorOrganizations dorg
                                      ON org.OrganizationID = dorg.OrganizationID
                                      WHERE dorg.DoctorID = '", doctor_id, "'"))
    return(org_df)
  }
  
  # Function to get secondary specialties of the Doctors
  # Parameters: Doctor ID
  # Returns: List of Specialties 
  get_specialties <- function(doctor_id){
    
    spcl <- dbGetQuery(con, paste0("SELECT GROUP_CONCAT(spcl.SpecialtyName SEPARATOR ', ') AS Specialties
                      FROM Specialties spcl
                      JOIN DoctorSpecialties dspcl
                      ON spcl.SpecialtyID = dspcl.SpecialtyID
                      WHERE dspcl.DoctorID = '",doctor_id , "' AND dspcl.IsPrimary = 0 AND spcl.SpecialtyName != ''"))
    return(spcl$Specialties)
  }
  
  # Function to get available appointment of Doctor
  # Parameters: Doctor ID
  # Returns: Dataframe with appointment details
  get_available_appointments <- function(doctor_id){
    
    available_appointments <- dbGetQuery(con, paste0("SELECT *
                      FROM AvailableAppointments
                      WHERE DoctorID = '",doctor_id , "'"))
    return(available_appointments)
  }
  
  # Logic for Tab switch
  observeEvent(input$tabs, {
    
    # Doctors Tab table
    if (input$tabs == "Doctors") {
      output$doctors_table <- renderDT({
        
        doctors_df <- get_doctors(0)
        
        # Render the modified data table
        DT::datatable(doctors_df,
                      selection = "single",
                      options = list(dom = 'Bfrtip',
                                     pageLength = 10,
                                     paging = TRUE,
                                     buttons = list('copy', 'excel', 'pdf', 'print'),
                                     columnDefs = list(list(targets = ncol(data),
                                                            searchable = TRUE,
                                                            orderable = FALSE,
                                                            className = 'dt-center'))))
      })
    }
  })
  
  # Logic when row is selected from Doctor's data table
  observeEvent(input$doctors_table_rows_selected, {
    # Assign values to variables
    doctors_df <- get_doctors(0)
    doctor_id <<- doctors_df[input$doctors_table_rows_selected, "DoctorID"]
    details_df <- get_doctors(doctor_id)[1, ]
    org_df <- get_doctor_org(doctor_id)
    address <- get_doctor_address(doctor_id)
    secondary_spcl <- get_specialties(doctor_id)
    available_appointments_df <- get_available_appointments(doctor_id)
    dates <- available_appointments_df$AppointmentDate
    time_slots <- available_appointments_df$ApppointmentTime
    
    # Logic to display details of Doctors 
    if(input$doctors_table_rows_selected > 0){
      output$details_ui <- renderUI({
        div(id = "details_ui",
            h3(paste0("Dr. ", details_df$DoctorName)),
            
            # Display Organization if present in DB
            if(length(org_df$OrganizationName) != 0){
              tags$p(org_df$OrganizationName)
              if(org_df$isHospital == 1){
                p("Hospital: YES")
              }
              else{
                p("Hospital: NO")
              }
            },
            
            # Display address
            p(address),
            
            # Display contact
            p(details_df$PhoneNumber),
            
            # Display specialties
            fluidRow(
              box(
                title = tags$h4(details_df$SpecialtyName, align = "center"), 
                width = 12, 
                background = "black",
                if(!is.na(secondary_spcl)){
                  tags$p(secondary_spcl, align = "center")
                }
              )
            ),
            
            fluidRow(
              # Display education details
              box(
                title = tags$h4("Education", align = "center"), 
                width = 4, 
                background = "green",
                p(paste0("Degree : ", details_df$Credential)),
                p(paste0("School : ", details_df$SchoolName)),
                p(paste0("Graduation Year : ", details_df$GraduationYear))
              ),
              
              # Display appointment booking box
              box(
                title = tags$h4("Appointment", align = "center"), 
                width = 4, 
                background = "yellow",
                
                # Display radio button for teleconsultation choice
                if(details_df$Teleconsultation == "Y"){
                  radioButtons("option", "Teleconsultation", choices = c("Yes", "No"), selected = "No")
                }
                else{
                  radioButtons("option", "Teleconsultation", choices = c("No"))
                },
                
                # Display input dropdown for time
                if(length(time_slots) > 0){
                  selectInput("select_time", "Select Time", choices = time_slots)
                },
                
                # Display input dropdown for date
                if(length(dates) > 0){
                  selectInput("select_date", "Select Date", choices = dates)
                },
                
                # Button to Book Appointment
                actionButton("book", "Book Appointment")
              ),
              
              # Display services of Doctor
              box(
                title = tags$h4("Services", align = "center"), 
                width = 4, 
                background = "green",
                p(paste0("Teleconsultation : ", details_df$Teleconsultation)),
                p(paste0("Individual Medicare : ", details_df$IndividualMedicare)),
                p(paste0("Group Medicare : ", details_df$GroupMedicare))
              )
            )
        )
      })
    }
  })
  
  # Function to insert booked appointment in DB
  # Parameters: Patient ID, Doctor ID, Appointment Date, Teleconsultation
  # Return: Status of query execution
  insert_appointment <- function(patient_id, doctor_id, appointment_date, appointment_time, teleconsultation){
    query <- paste0("INSERT INTO Appointments(PatientID, DoctorID, AppointmentDate, AppointmentTime, Teleconsultation) VALUES (",patient_id,",",doctor_id,",'",appointment_date,"','",appointment_time,"','",teleconsultation,"')")
    return(dbExecute(con, query))
  }
  
  # Function to delete available appointment of Doctor
  # Parameters: Doctor ID, Appointment Date, Appointment Time
  # Return: Status of query execution
  delete_available_appointment <- function(doctor_id, appointment_date, appointment_time){
    query <- paste0("DELETE FROM AvailableAppointments WHERE DoctorID = ",doctor_id," AND AppointmentDate = '",appointment_date,"' AND ApppointmentTime = '",appointment_time,"'")
    return(dbExecute(con, query))
  }
  
  # Logic when Book appointment is clicked
  observeEvent(input$book, {
    patient_id <- get_patient(input$email)$PatientID
    if(input$option == "Yes"){
      teleconsultation <- 'Y'
    }
    else{
      teleconsultation <- 'N'
    }
    appointment_date <- input$select_date
    appointment_time <- input$select_time
    
    # Check if insertion of appointment in DB is successful
    if(insert_appointment(patient_id, doctor_id, appointment_date, appointment_time, teleconsultation) > 0){
      # Delete the available appointment for that Doctor
      if(delete_available_appointment(doctor_id, appointment_date, appointment_time) > 0){
        # Display message for successful booking
        showModal(modalDialog(
          title = "Booking successful",
          paste0("Please be prepared for your appointment"),
          easyClose = TRUE,
          footer = NULL
        ))
        # Navigate to the Appointments Tab
        updateTabItems(session, "tabs", "Appointments")
      }
    }
    else{
      # Display message for unsuccessful booking
      showModal(modalDialog(
        title = "Booking Unsuccessful",
        "There is some issue in booking this Appointment. Please try again.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    
  })
  
  
  #Appointments Tab Functionality
  
  # Function to get the appointment details of logged in patient
  # Parameters: Patient ID
  # Return: Dataframe with Appointment details
  get_appointments <- function(patient_id){
    appointments_df <- dbGetQuery(con, paste0("SELECT AppointmentID, DoctorID, DoctorName, Teleconsultation, AppointmentDate, AppointmentTime
                                  FROM appointment_details
                                  WHERE PatientID = '",patient_id,"'"))
    return(appointments_df)
  }
  
  # Function to get the old appointment details
  # Parameters: Appointment ID
  # Return: Dataframe with old appointment details
  get_old_appointment <- function(appointment_id){
    old_appointment <- dbGetQuery(con, paste0("SELECT *
                                  FROM Appointments
                                  WHERE AppointmentID = '",appointment_id,"'"))
    
    return(old_appointment)
  }
  
  # Display datatable of appointments
  output$appointments_table <- renderDT({
    
    appointments_df <- get_appointments(patient_id)
    updated_appointments_df <- subset(appointments_df, select = -DoctorID)
    # Render the modified data table
    DT::datatable(updated_appointments_df,
                  selection = "single",
                  options = list(dom = 'Bfrtip',
                                 pageLength = 5,
                                 paging = TRUE,
                                 buttons = list('copy', 'excel', 'pdf', 'print'),
                                 columnDefs = list(list(targets = ncol(updated_appointments_df),
                                                        searchable = TRUE,
                                                        orderable = FALSE,
                                                        className = 'dt-center'))),
                  escape = FALSE)
  })
  
  # Logic when row in appointments table is clicked
  observeEvent(input$appointments_table_rows_selected, {
    # Assign values to variables
    appointments_df <- get_appointments(patient_id)
    appointment_id <<- appointments_df[input$appointments_table_rows_selected, "AppointmentID"]
    appointment_doctor_id <- appointments_df[input$appointments_table_rows_selected, "DoctorID"]
    doctor_name <- appointments_df[input$appointments_table_rows_selected, "DoctorName"]
    appointment_date <- appointments_df[input$appointments_table_rows_selected, "AppointmentDate"]
    appointment_time <- appointments_df[input$appointments_table_rows_selected, "AppointmentTime"]
    teleconsultation <- appointments_df[input$appointments_table_rows_selected, "Teleconsultation"]
    doctor_teleconsultation <- dbGetQuery(con, paste0("SELECT Teleconsultation FROM Services
                                                      WHERE DoctorID = ", appointment_doctor_id))
    available_appointments_df <- get_available_appointments(appointment_doctor_id)
    dates <- available_appointments_df$AppointmentDate
    time_slots <- available_appointments_df$ApppointmentTime
    
    # Display the modification/ cancellation option for selected appointment
    if(input$appointments_table_rows_selected > 0){
      output$appointment_ui <- renderUI({
        div(id = "appointment_ui",
            fluidRow(
              column(
                8,
                offset = 4,
                box(
                  title = tags$h3(paste0("Appointment ID : ", appointment_id), align = "center"),
                  background = "black",
                  h4(paste0("Dr. ", doctor_name)),
                  
                  # Condition to assign default value to the selected radio button
                  if(doctor_teleconsultation$Teleconsultation == "Y" & teleconsultation == "Y"){ 
                    radioButtons("option_modify", "Teleconsultation", choices = c("Yes", "No"), selected = "Yes")
                  }
                  else{
                    radioButtons("option_modify", "Teleconsultation", choices = c("Yes", "No"), selected = "No")
                  },
                  
                  # Display radio button for teleconsultation
                  
                  # Display input for date
                  if(length(dates) > 0){
                    selectInput("modify_date", "Select Date", choices = dates, selected = appointment_date) 
                  },
                  
                  # Display input for time
                  if(length(time_slots) > 0){
                    selectInput("modify_time", "Select Time", choices = time_slots, selected = appointment_time)
                  },
                  
                  # Button for modifying appointment
                  actionButton("modify", "Modify", class = "btn-warning"),
                  
                  # Button for cancelling appointment
                  actionButton("cancel", "Cancel", class = "btn-danger")
                )
              )
            )
        )
      })
    }
  })
  
  # Function to update the appointment
  # Parameters: Appointment ID, Patient ID, Date, Time, Teleconsultation
  # Returns: Status of query execution
  update_appointment <- function(appointment_id, patient_id, appointment_doctor_id, appointment_date, appointment_time, teleconsultation){
    query <- paste0("UPDATE Appointments 
                    SET PatientID = ",patient_id,", 
                    DoctorID = ",appointment_doctor_id,", 
                    AppointmentDate = '",appointment_date,"', 
                    AppointmentTime = '",appointment_time,"', 
                    Teleconsultation = '",teleconsultation,"' 
                    WHERE AppointmentID = ",appointment_id)
    return(dbExecute(con, query))
  }
  
  # Function to insert deleted appointment in available appointments
  # Parameters: Doctor ID, Date, Time
  # Returns: Status of query execution
  insert_available_appointment <- function(appointment_doctor_id, appointment_date, appointment_time){
    query <- paste0("INSERT INTO AvailableAppointments VALUES (",appointment_doctor_id,",'",appointment_date,"','",appointment_time,"')")
    return(dbExecute(con, query))
  }
  
  # Function to delete the appointment
  # Parameters: Appointment ID
  # Returns: Status of query execution
  delete_appointment <- function(appointment_id){
    query <- paste0("DELETE FROM Appointments WHERE AppointmentID = ",appointment_id)
    return(dbExecute(con, query))
  }
  
  # Logic when Cancel Appointment button is clicked
  observeEvent(input$cancel, {
    
    # Get details of initial appointment
    deleted_appointment <- get_old_appointment(appointment_id)
    
    if(delete_appointment(appointment_id) >0){
      # Check if insertion of deleted appointment in available appointments is successful in DB
      if(insert_available_appointment(deleted_appointment$DoctorID, deleted_appointment$AppointmentDate, deleted_appointment$AppointmentTime) > 0){
        # Display message when appointment gets cancelled
        showModal(modalDialog(
          title = "Appointment Cancelled",
          easyClose = TRUE,
          footer = NULL
        ))
        
        # Update Appointments table
        updateTabItems(session, "tabs", "Appointments")
        appointments_df <- get_appointments(patient_id)
        updated_appointments_df <- subset(appointments_df, select = -DoctorID)
        DT::replaceData(proxy = DT::dataTableProxy("appointments_table"), data = updated_appointments_df)
      }
    }
    else{
      # Display message when cancellation is not successful
      showModal(modalDialog(
        title = "Cancellation Unsuccessful",
        "There is some issue in cancelling this Appointment. Please try again.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  # Logic when Modify Appointment button is clicked
  observeEvent(input$modify, {
    
    if(length(input$option_modify) != 0 ){ 
      # Assign values to variables
      if(input$option_modify == "Yes"){
        teleconsultation <- 'Y'
      }
      else{
        teleconsultation <- 'N'
      }
    }
    appointment_date <- input$modify_date
    appointment_time <- input$modify_time
    old_appointment <- get_old_appointment(appointment_id)
    appointment_doctor_id <- old_appointment$DoctorID
    
    # Check if update is successful in DB
    if(update_appointment(appointment_id, patient_id, appointment_doctor_id, appointment_date, appointment_time, teleconsultation) > 0){
      # Check if deletion of available appointment is successful
      if(delete_available_appointment(appointment_doctor_id, appointment_date, appointment_time) > 0){
        # Check if the initial appointment is inserted again in DB
        if(insert_available_appointment(appointment_doctor_id, old_appointment$AppointmentDate, old_appointment$AppointmentTime) > 0){
          # Display message when updation is successful
          showModal(modalDialog(
            title = "Appointment Modified",
            paste0("Please be prepared for your new appointment"),
            easyClose = TRUE,
            footer = NULL
          ))
          # Update the appointments table
          updateTabItems(session, "tabs", "Appointments")
          appointments_df <- get_appointments(patient_id)
          updated_appointments_df <- subset(appointments_df, select = -DoctorID)
          DT::replaceData(proxy = DT::dataTableProxy("appointments_table"), data = updated_appointments_df)
        }
      }
    }
    else{
      showModal(modalDialog(
        # Display message when modification fails
        title = "Modification Unsuccessful",
        "There is some issue in booking this Appointment. Please try again.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
    
  })
  
  # Logic to toggle to Appointments tab
  observeEvent(input$appointments, {
    updateTabItems(session, "tabs", "Appointments")
  })
  
  
  # Logout Functionality
  observeEvent(input$logout, {
    # Set logged in state
    logged_in(FALSE)
    
    # Disconnect database
    dbDisconnect(con)
  })
  
}

# Run the app
shinyApp(ui = fluidPage(uiOutput("main_content")), server)