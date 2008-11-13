ACCELA is a library of C++ wrapper classes for the Mac OS Carbon toolbox. While some parts are still work-in-progress, others, especially the CarbonEvent classes, have been tested and are working well.

The wrapper classes all have the prefix A in their names; X is used for other utility classes. The two most important X classes are the templates XRefCountObject and XWrapper. XRefCountObject is used to wrap objects that use reference counting, such as Carbon Events and Core Foundation objects. XWrapper is used for the simpler create/dispose objects.

Although ACCELA does little beyond wrapping toolbox calls, the Carbon Event system greatly reduces the need to go much further. My goal is to make it as easy to make an application with ACCELA and InterfaceBuilder as it is with PowerPlant and Constructor. One problem is that nib files are not as flexible and powerful as PPob files; in order to achieve this goal, it may be necessary to replace nibs altogether.

The file archives are marked by date instead of by version number because ACCELA contains many different parts that are evolving somewhat independently. Also, if you are going to use ACCELA in your own development, I recommend you use CVS to keep up to date instead of relying on the archive postings. Information on getting ACCELA by CVS is here:
<http://sourceforge.net/cvs/?group_id=55669>

I am using ACCELA in my own development, mainly in Icon Machine and Volley. For more information on these:
<http://www.uncommonplace.com/shareware/iconmachine.html>
<http://volleyserver.sourceforge.net>

Feedback is most welcome. Send questions, suggestions, or what have you to me at uncommon@uncommonplace.com.