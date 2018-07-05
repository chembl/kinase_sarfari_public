// $Id: sarfari.2.js 602 2010-04-12 09:50:59Z sarfari $

// SEE LICENCE

//Following function has been taken from jQuery tutorial:
//http://15daysofjquery.com/wrap-it-up-pretty-corners/13/
$(document).ready(function(){ 
	$("div.roundBox") .wrap('<div class="dialog">'+ 
			'<div class="bd">'+ 
			'<div class="c">'+ 
			'<div class="s">'+ 
			'</div>'+ 
			'</div>'+ 
			'</div>'+ 
	'</div>');

	$('div.dialog:not("#skipAuotRoundbox")').prepend('<div class="hd">'+
			'<div class="c"></div>'+
	'</div>')
	.append('<div class="ft">'+
			'<div class="c"></div>'+
	'</div>');
});


function setupMenuDisplay(tab){
	
	var currentFormOnDisplay = (tab) ? tab : 0;
	
	$("#searchForms div").hide();
	$("#searchForms div").eq( currentFormOnDisplay ).show();
	$("#searchMenu th:gt("+currentFormOnDisplay+")").find('img').hide();
	$("#searchMenu th:lt("+currentFormOnDisplay+")").find('img').hide();
			
    $('#searchMenu td').click(
        function(){
		    var index = $("#searchMenu td").index(this);
		    var select_img = "<img src='[% c.uri_for('/static/images/lgeneral/select.png') %]' />";
			$("#searchMenu th:gt("+index+")").find('img').hide();
			$("#searchMenu th:lt("+index+")").find('img').hide();
		    $("#searchMenu th:eq("+index+")").find('img').show();
			
			$("#searchForms > div").eq( currentFormOnDisplay ).hide();
			$("#searchForms > div").eq(index).show();
			currentFormOnDisplay = index;
			
			if($(this).attr('id')){
				$.cookies.set('ks_submenu',$(this).attr('id'));
			}			
        }
    );
    
    // Click on submenu if defined
	if($.cookies.get('ks_submenu')){
		var sm = $.cookies.get('ks_submenu');
		$("#"+sm).click();
	}
}


function compoundPopUp(url){
    var target_name = 'marvin_pop_up';
    popUp = window.open(url,target_name,'toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,width=550,height=500');	               
    popUp.focus();
}


function runTargetSearch(form, type){
	if(validateTargetForm(form, type))
		form.submit();
}


function runCompoundSearch(form, type){
	if(validateCompoundForm(form, type))
		form.submit();
}


function runBioactivitySearch(form, type){
	if(validateCompoundForm(form, type))
		form.submit();
}


function runCompoundTargetSearch(form, type){
	if(validateTargetForm(form, type) && validateCompoundForm(form, type))
		form.submit();
}


function validateTargetForm(form, type){
	
	if(form.targetList.value.length < 1 && form.targetFile.value.length < 1){
		if(type == 2)
			form.formerror.value = "Please paste or upload a fasta formated protein sequnce before submitting search";		
		else
			form.formerror.value = "Please fill in or upload target search terms (whitespace separated) before submitting search";		
		
		return;
    }
	
	form.formerror.value = "";
	return 1;
}


function validateCompoundForm(form, type){
	
	if(form.compoundList.value.length < 1 && form.compoundFile.value.length < 1){
		form.formerror.value = "Please fill in or upload compound search terms (whitespace separated) before submitting search";
		return;
    }
	
	form.formerror.value = "";
	return 1;
}


function bioFilterOn(form,filterName){
	form.elements[filterName].checked = 1;
}


function validateNumericInput(form, inputName, inputValue){
	
	if(inputValue.length > 0 && !isFinite(inputValue)){
		form.formerror.value ="Please update filter input value, '"+inputValue + "' is not a number.";
		form.elements[inputName].value = "";
		return;
    }
	
	return;
}


function validateCheckboxes(form){
	 
	var selected = $("input:checked").length;
	
	if(selected<1){
		form.formerror.value ="Please use checkboxes to select 1 or more domains before submiting form";
		return 1;
    }
	
	form.formerror.value ="";
	
	return;
}


function validateSuperpos(form){
	 
	var selected = $("input:radio:checked").length;
	
	if(selected<1){
		form.formerror.value ="Please select 1 reference structure (Ref) and 0 or more mobile structures (Mob) before submiting form";
		return 1;
    }
	
	form.formerror.value ="";
	
	return;
}


