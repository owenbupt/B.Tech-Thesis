# BTP
Details on the project
The current study proposes an approach that leverages site survey done by any mobile phone only once, 
which is utilized by other phones by calibrating their RSS values logged at only 5 points against it. 
This is achieved without any assumptions about the site, the placement of access points (AP) or additional costs of 
infrastructure installment.
Our approach uses a primary device to log the site once, using which, the location of other devices can be determined. 
This is possible due to calibration of the new devices against the primary device, but with minimal training points required 
for these devices.
This optimization is not at the cost of accuracy which has been shown to be as good as the accuracy when the entire fingerprint 
for a phone is available. 
Cross-Calibration.m - This file helps to cross-calibrate different phones against the primary device and predicting the location
(using modified kNN)
recursive_bagging_multiple-  This helps in identifying the best locations to log in an indoor environment
Error_Grayscale.m - This plots the error graphs to know the accuracy
Fall_2015_BTP_Report.pdf - This details my thesis. [Last updated Decemember 2015]