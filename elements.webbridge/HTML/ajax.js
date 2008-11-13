	Event.observe(window, 'load', init, false);
	
	function init(){
		$('greeting-submit').style.display = 'none';
		Event.observe('greeting-name', 'keyup', greet, false);
	}

	function greet(){
	  	var url = 'greeting.php';
		var pars = 'greeting-name='+escape($F('greeting-name'));
		var target = 'greeting';
		var myAjax = new Ajax.Updater(target, url, {	method: 'get',	parameters: pars});
	}
	
