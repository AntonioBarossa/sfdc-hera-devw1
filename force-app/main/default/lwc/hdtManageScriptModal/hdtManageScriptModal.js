
/*
 * File: hdtManageScriptModal.js
 * Project: HERA
 * File Created: Monday, 7th June 2021 2:02:59 pm
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */


import getHTMLScript from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.getScriptSections2';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, wire } from 'lwc';

export default class HdtManageScriptModal extends LightningElement {

    @api scriptProcessName;//button Label or Process
    @api recordId;//record starting Object

    openModal;

    htmlScriptList;
    scriptIndex;

/* 

    @wire(getHTMLScript, {processName : '$scriptProcessName', recordId : '$recordId'})
    setRichText({error, data}){
        if (data) {
            console.log("data recived")
            this.htmlScriptList=data;
            if(!this.scriptIndex){
                this.scriptIndex=0;
            }
        } else if (error) {
            console.log(error)
            this.showGenericErrorToast()
        }
    }  cannot be cached, must call imperatively
    
    */
    
    showGenericErrorToast() {
		this.showToast('error', 'Errore', 'Si è verificato un errore. Ricaricare la pagina e riprovare. Se il problema persiste contattare il supporto tecnico.');
	}
	
	showToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({
			variant: variant,
			title: title,
			message: message
		}));
	}
    
    connectedCallback(){
        if(!this.scriptProcessName){
            this.scriptProcessName='Mini Vocal Order';
            this.recordId='a3g1j000000XPX7AAO';
        }
    }

    _linkReitek;//private var
    get linkReitek(){
        return this._linkReitek;
    }
    set linkReitek(value){
        this._linkReitek=value;
        if(!value){
            this.enableConfirmButton();
        }
    }

    get indexNotZero(){
        return this.scriptIndex>0;
    }

    get indexNotLast(){
        return this.htmlScriptList.length > (this.scriptIndex+1);
    }

    prevSection(){
        this.scriptIndex-=1;
    }
    nextSection(){
        this.scriptIndex+=1;
    }

    get htmlScriptText(){
        return this.htmlScriptList[this.scriptIndex].sectionText;
    }

    get htmlScriptTitle(){
        return this.htmlScriptList[this.scriptIndex].sectionLabel;
    }

/*     
    @api
    get buttonLabel(){
        return this._buttonLabel;
    }
    set buttonLabel(value){
        this._buttonLabel
    }
 */

    
    

    async showModal(){
        this.htmlScriptList=  await getHTMLScript({processName : this.scriptProcessName, recordId : this.recordId});
        console.log(this.htmlScriptList);
        this.scriptIndex=0;
        this.openModal=true;
    }

    closeModal(){
        this.openModal=false;
    }
    saveRecLink(){
        let link= this._linkReitek;
        //do stuff
        this.closeModal();
    }

    enableConfirmButton(){
        let btConferma = this.template.querySelector('[data-id="scriptModalBt"]');
        btConferma.disabled=false;
    }



}