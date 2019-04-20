# ConsoleFree HER
A well-visualized tool for Humanity Entity Recognizer

HER is white box solution for robust handling of different types of entities, different languages, styles, and domains, and varying levels of structure in texts, by [Alex Erdmann](ae1541@nyu.edu)

ConsoleFree HER visilized the console-base HER by change the white-box solution to black-box, in other word, user is not 
necessary any more to know shell command, pyhton and linux envireoment setting up to use HER

## Background
The console-base HER has been widely and frequenly using by 
linguistic department of The Ohio State University for acdemic using right after the HER was post on [github](https://github.com/alexerdmann/HER).But the actual use efficiency of HER is not as high as envisaged. Since most of the actual users in linguistic department have no common-sence in Computer science field, such as basic opreatios on linux system and setting up python enveriment.
The whole annotating process is by typing in txt file, when working repetitively for a long time, it is very easy to make mistakes such as typo for user.
Plus consonle-base HER can't solve the problem that in most cases, multiple people need to work together to complete a annotating, and HER doesn't support share unfinished work cross users.
## Introduction
In order to solve the problem HER currently have, Alex's group appointed FeatureNotBug, which is led by a group member of Alex's group - Yukun,to find a efficent visualize solution to HER.
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