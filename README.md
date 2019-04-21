# ConsoleFree HER
A well-visualized tool for Humanity Entity Recognizer[HER].


## Background
HER is developed by [Alexander Erdmann](ae1541@nyu.edu) and supported by [Herodotus group of the Linguistic Department](https://u.osu.edu/herodotos/) 
in The Ohio State University. It is an active learning system that could reduce the time and cost for NER annotation task, 
which is able to handle multiple languages, user-defined entity types, and different sort methods. 
However, the original HER is only a white box solution for such an annotation problem, although it could largely 
reduce the annotation cost from the algorithm side, it is still hard for annotators to use in the real annotation process 
since the whole system is based shell commands and text editing, which annotators are not familiar with at all.

The original HER has been widely used by the annotators in the Herodotus group. Normally, most annotators are the experts 
in the linguistic but not computer science. Therefore, current annotating environment is not friendly to them at all. Also, 
it is easy to make mistakes when using text editor to annotate a large amount of data. In addition, since annotators are 
usually working on the same corpus, it is really hard to split the data into partitions for each annotator, which also 
largely reduces the efficiency of the active learning algorithm.


## Introduction
ConsoleFree HER addresses such problem by visualizing the original HER to a web interface, which changes the 
white-box solution to a black-box. In this case, annotators does not need to use or see any shell commands. Instead, they
can do the annotation in a very user-friendly environment, by simply moving the mouse and clicking the entity. Also, 
ConsoleFree HER supports multiple users sharing one repository, which is very important for the whole active learning process. 

## Functionality

* Based on Rails Framwork, reduced development problems and simplified many complicated actions. 
* Established a remote server, user can acess and useing HER at anywhere with Internet
* In User center, user could have several reposities at the same time, and they can have different progress
* Using modal to simplify the whole view structur, to finish the whole process(include sign up, creat repository, annotating and cheack result) with in *three* pages
* Using nice background color for different annotating tag, easy to distinguish
* WYSIWUG (what you see is what you get), right after centain tag been annotated, the background color of that tag will instanly change
* Fault tolerence impore by adding History block, before tag been updaload into sever, user can still find annotated sentences in history block and correct any error.
* Decentralized operation or decrease the chance of Computer crash, the file could be update anytime they want by clicking update button.
* Visual progress bar, user could determine rounghly how many seed they has anotated and how many left
* Repositories could be share to other user in the same sytem. Theoretically, there is not upper bound number of shared user. But they cannn't annotating the same  repositories at the same time.
## Need More

## Implementation Details

### Requirement to Run
### Front-End
The group using 
### Server-End
## Future work







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