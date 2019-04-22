# ConsoleFree HER
A well-visualized tool for Humanity Entity Recognizer [[HER]](https://github.com/alexerdmann/HER).

Currently, the server is running on Google Cloud Platform. Click [HERE](http://35.245.75.7:3000) to see our website.

## Background
HER is developed by [Alexander Erdmann](ae1541@nyu.edu) and supported by [Herodotus group of the Linguistic Department](https://u.osu.edu/herodotos/) 
in The Ohio State University. It is an active learning system that reduces the time and cost for NER annotation task, 
which is able to handle multiple languages, user-defined entity types, and different sort methods. 
However, the original HER is only a white box solution for such an annotation problem, although it could largely 
reduce the annotation cost from the algorithm side, it is still hard for annotators to use in the real annotation process 
since the whole system is based shell commands and text editing, which annotators are not familiar with at all.

The original HER has been widely used by the annotators in the Herodotus group. Normally, most annotators are the experts 
in the linguistic but not in computer science. Therefore, current annotating environment is not friendly to them at all. Also, 
it is easy to make mistakes when using text editor to annotate a large amount of data. In addition, since annotators are 
usually working on the same corpus, it is really hard to split the data into partitions for each annotator, which also 
largely reduces the efficiency of the active learning algorithm.


## Introduction
ConsoleFree HER addresses such problem by visualizing the original HER to a web interface, which changes the 
white-box solution to a black-box. In this case, annotators does not need to use or see any shell commands. Instead, they
can do the annotation in a very user-friendly environment, by simply moving the mouse and clicking the entity or pressing hot-keys. Also, 
ConsoleFree HER supports multiple users sharing one repository, which is very important for the whole active learning process. 

## Client-View ---- Functionality
* A very user-friendly environment
* No scripts and shell commands for users
#### Account and Repository Management
* A system for user to sign up and log in
* The user is able to see all the repositories when logged in
* The user is able to define his or her own entity types
* The user is able to select any language and sort method
* The user is able to upload multiple data files
* The user is able to share the repository with other users
* The user is bale to delete any repository

#### Annotation Process
* Enough information alert to let the user know what he or she is doing
* Large space and big font to display the annotating sentence
* Simply move the mouse and click to select the entity type
* Entity types are differentiated by multiple colors
* A progress bar to display the current status
* Only several buttons for users to use, all the process are implemented in the back-end
* Next-Button: Puts the current sentence to cache, which could be modified later, and get next sentence
* Update-Button: Update current and cache sentences to file, which cannot be modified
* Eval-Rank-Button: Do evaluation and ranking every time the user wants to stop
* Result-Button: Download the result of gazetteers and final inferences 
* The user could modify the cache data by simply clicking the sentence in the history bar

## Implementor-View ---- Details
The entire is based rails framework. We have established a remote server running on Google Cloud Platform, 24/7.

#### General Request Pipeline:  
*HTML --> Javascript --> Ajax --> Route --> Controller --> Database --> Controller --> Respond-Ajax --> Javascript --> HTML*
#### DataBase
* User table: username(unique), password
* Repo table: repo_name, entity_types, language, sort_method, seed_size, status
* A relational table that creates N to M relations for users and repos tables
* The entire database design has a clear functional dependency, which satisfies the third normalization

#### Front-End
* All web pages have similar theme in the UI design
* Use bootstrap to create modals, progress-bar and buttons
* Use a dropdown div for annotation and a hover is added on each word to trigger the dropdown function
* Use modal to simplify the whole view structure within *THREE* pages
* Use cookies for user authentication in every post and get
* Use regular expression to validate username and password before post action
* Use jQuery to simplify sending ajax request, initializing ready function and etc.
#### Server-End
* Redirect all invalid routes to an error 404 page
* Use ajax to transfer data transfer between server and user
* Use JSON to parse data between javascript object and ruby object
* Use a recursive function to upload multiple files 
* Use success functions in ajax to make sure there is no synchronization issue
#### Back-End
* A before-action function to find specific directory path for certain repository
* Use system call to execute the python script and shell commands on server host
* Set up a new workspace on server under HER-data folder when a new repository is created
* Check the seed progress by tracking the line number
* Run cross-validation, ranking, and pre-tagging if seed is finished

## Future work
* Collect feedback from annotators
* Make it support more model options for final inference: CNN-BiLSTM, BiLSTM-CRF
* Test and debug more security issues for the entire system
* Try to improve the status attribute in repository table

## Acknowledgement
#### Contributors
* Feng, Yukun ---- [feng.749@osu.edu](feng.749@osu.edu)
* Li, Feng ---- [li.8906@osu.edu](li.8906@osu.edu)  
* Chen, Xiaoyuan ---- [chen.6400@osu.edu](chen.6400@osu.edu)

*All contributors have equal contributions to this work.*

#### Information
* This project is developed by FeatureNotBug as a class project in CSE3901(SP19 8117).
* This project is a Web-UI for Alex's HER system.  
* This project should be used for Academic Purpose, ONLY.  
#### Back-End HER --- Supported by Alexander Erdmann
* [Quick Start Demo](https://github.com/alexerdmann/HER)
* [User Manual](https://github.com/alexerdmann/HER/blob/master/Scripts/Docs/Manual.md)
* Publication Accepted by NAACL 2019:  
Alexander Erdmann, David Joseph Wrisley, Benjamin Allen, Christopher Brown, Sophie Cohen Bodénès, Micha Elsner, Yukun Feng, Brian Joseph, Béatrice Joyeaux-Prunel and Marie-Catherine de Marneffe. 2019. [“Practical, Efficient, and Customizable Active Learning for Named Entity Recognition in the Digital Humanities.”](https://github.com/alexerdmann/HER/blob/master/HER_NAACL2019_preprint.pdf) In Proceedings of North American Association of Computational Linguistics (NAACL 2019). Minneapolis, Minnesota.

#### Special Thanks:
* [Herodotus Group](https://u.osu.edu/herodotos/) of Linguistic Department in OSU
* Senior UI Designer: Xiangru Chen
* [Deepin](https://www.deepin.org/en/) Operating System

#### Questions & BugReports
Please contact ANY contributor with any questions, concerns, bug fixes, or helpful advice.