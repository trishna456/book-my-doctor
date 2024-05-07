# Medical Appointment Booking Platform
## Applied Database Technologies (DSCI - D532) - Project Proposal

### Project Summary
The Medical Appointment Booking Platform will serve as a portal for patients to book medical appointments with available doctors and clinicians from a database created by utilizing data from The Centers for Medicare & Medicaid Services (CMS). The platform will also help patients decide which doctor to choose based on factors such as education, experience, specialty, and location, among others. This will be achieved by visualizing the data present in the database on the dashboard before booking an appointment.

### Project Description

#### Team
| Name | Course | Role |
| --- | --- | --- |
| Ameya Dattaram Parab | M.S. Data Science | Developer |
| Trishna Patil | M.S. Computer Science | Developer |

#### Objectives
The project aims to implement a platform to assist patients in selecting a suitable doctor or clinician for their consultation. The data gathered for this purpose will be normalized into several tables, and a schema will be defined in the RDBMS. Some new tables will also be created to handle patient and appointment information. The platform will feature a dashboard to visualize the data of doctors' education, experience, specialty, location, and other relevant factors. Additionally, the site will include search, sort, and filter features to segregate the results retrieved through the database. The analytics performed on the database will ultimately help patients select a doctor with the necessary specialty and ideal experience.

#### Usefulness
Currently, there are various websites and applications on the market that patients use to reserve medical appointments. For example, Docon and Sminq are mobile-based applications that provide doctor search, clinic addresses, and appointment booking features. However, these applications do not provide detailed information about the doctors and only focus on the functionality of booking and tracking appointments. There are several negative reviews of these two applications regarding payment issues and finding an appropriate doctor. Some users have suggested adding filters for the doctor's specialty and location. Additionally, the Docon app requires payment in advance for booking an appointment, which may make patients hesitant to use such applications as they may be uncertain about the doctor's complete information and expertise. Although these two applications are patient-oriented, neither provides analytics on the education, experience, and specialty of the doctors, which can help patients make an appropriate decision before booking an appointment. The users who will be using the site will be patients trying to get an appointment with doctors belonging to a specific specialty and location. This platform, through its visualization feature and detailed display of information on doctors and clinicians, will provide a better way for patients to compare and analyze before booking medical appointments with suitable doctors. Furthermore, it will be easier for users to find doctors through filters for location, specialty, and other similar attributes.

#### Dataset
The National Downloadable File, along with Physician-Facility Affiliations, contains all the raw data in CSV format that will be utilized for this project. These datasets are taken from the Doctors and Clinicians section of The Centers for Medicare & Medicaid Services website, a U.S. government website for obtaining healthcare-related data about health services, physicians, Medicare services, hospitals, and facilities. The Provider Enrollment, Chain, and Ownership System (PECOS) is the primary source of information about physicians and clinicians in the Provider Data Catalog and on Medicare Care Compare profile pages. It is updated every two months with the latest possible information about physicians, incorporating changes such as the attribute for telehealth services and additional facility types.
