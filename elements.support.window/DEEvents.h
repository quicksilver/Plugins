/******************************************************************************
* 
* Peony.Virtue 
*
* A desktop extension for MacOS X
*
* Copyright 2004, Thomas Staller 
* playback@users.sourceforge.net
*
* See COPYING for licensing details
* 
*****************************************************************************/ 

#ifndef __VT_DE_EVENTS_H__
#define __VT_DE_EVENTS_H__ 


/**
 * @defgroup Group_Virtue_DE_Events Events 
 * @ingroup  Group_Virtue_DE
 * 
 * Events provided by the Virtue Dock Extension
 *
 */ 


/**
 * @brief	Class for dock extension events 
 * @ingroup Group_Virtue_DE_Events
 *
 * @todo	Make use of the four character code generation macros to be byte alignment
 *			safe in these constants. 
 */ 
enum {
    kDockExtensionClass = 'DExt'
};


/**
 * @brief	Event descriptors for dock extension events 
 * @ingroup Group_Virtue_DE_Events
 *
 * @todo	Make use of the four character code generation macros to be byte alignment
 *			safe in these constants. 
 */ 
enum
{
	/**
	 * @brief	Triggers Window Fading Out
	 *
	 * @param   wid		The window id of the window to fade out 
	 * @param   dur		The duration in seconds 
	 * @param	wal		The target alpha value 
	 * 
	 */ 
	kDockExtensionFadeOutWindow	= 'DEfo',

	/**
	 * @brief	Triggers Window Fading In
	 *
	 * @param   wid		The window id of the window to fade in 
	 * @param   dur		The duration in seconds 
	 * @param	wal		The target alpha value 
	 */ 
	kDockExtensionFadeInWindow	= 'DEfi',
	
	/**
	 * @brief   Triggers Window ordering out 
	 *
	 * @param   wid		The window id of the window to order out
	 */ 
	 kDockExtensionOrderOutWindow = 'DEow', 
	 
	/**
	 * @brief   Triggers Window ordering in 
	 *
	 * @param   wid		The window id of the window to order in 
	 */ 
	kDockExtensionOrderInWindow = 'DEiw', 
	
	/**
	 * @brief   Triggers Window ordering 
	 *
	 * @param   wid		The window id of the window to order 
	 * @param   rid		The reference window id 
	 * @param   ort		The ordering type 
	 *
	 */ 
	kDockExtensionOrderWindow = 'DErw',
	
	/**
	 * @brief   Moves the window to the specified desktop
	 *
	 * @param   wid		The window id of the window to move 
	 * @param   wsp		The workspace id to move it to 
	 */
	 kDockExtensionSetWorkspaceForWindow = 'DEww', 

	/**
	 * @brief   Moves the windows to the specified desktop
	 *
	 * @param   wid		The window id of the window to move 
	 * @param   wsp		The workspace id to move it to 
	 */
	 kDockExtensionSetWorkspaceForWindows = 'DEwl', 
	 
	 /**
	  * @brief  Makes the window sticky 
	  *
	  * @param  wid		The window to make sticky 
	  *
	  */
	  kDockExtensionMakeSticky = 'DEws', 
	  
	  /**
	   * @brief Makes the window non sticky
	   *
	   * @param wid		The window to make non-sticky
	   *
	   */
	   kDockExtensionMakeNonSticky = 'DEwn',
	   
	   /**
	    * @brief	Triggers desktop selection mode
		* 
		* @param	wsc		The count of elements in the following list 
		* @param	wsl		The workspace list containing workspace indices to 
		*					provide in the selection 
		* @param	wtc		The count of elements in the following list 
		* @param	wtl		The target transformations for the workspaces to 
		*					show
		* 
		*/ 
		kDockExtensionArrangeDesktops = 'DEwa', 
	
		/**
		 * @brief   Sets alpha value for the passed windows 
		 *
		 * @param   wid		The window list 
		 * @param   wal		The new alpha value
		 *
		 */ 
		kDockExtensionSetAlphaForWindows = 'DEal',
	
		/**
		 * @brief	Sets alpha value for a single window 
		 *
		 * @param	wid		The window 
		 * @param	wal		The new alpha value 
		 * @param	wan		Indicates if we should animate 
		 * @param	dur		Duration of animation
		 *
		 */ 
		kDockExtensionSetAlphaForWindow = 'DEas',
}; 

#endif 
