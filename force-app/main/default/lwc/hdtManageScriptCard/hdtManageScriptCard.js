/*
 * File: hdtManageScriptCard.js
 * Project: HERA
 * File Created: Tuesday, 15th June 2021 11:46:30 am
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 */

import getHTMLScript from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.getScriptSections';
import saveReitekLink from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.saveReitekLink';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, wire } from 'lwc';

export default class HdtManageScriptCard extends LightningElement {

    @api scriptProcessName;//Script Process
    @api recordId;//record starting Object
    @api activityId;
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title
    @api hasLink;

    htmlScriptList;
    scriptIndex;
    @wire(getHTMLScript, {processName : '$scriptProcessName', 
        recordId : '$recordId', 
        childRecordIdentifier : '$childAdditionalInfo'})
        getScript({ data, error }) {
            if(data){
                this.htmlScriptList= data;
                if(this.htmlScriptList.length==0){
                    this.showToast('error', 'Non è disponibile lo script per questa campagna!');
                    this.closeModal();
                }else{
                    console.log(this.htmlScriptList);
                    console.log("ok deploy")
                    this.scriptIndex=0;
                }

                //this.openModal=true;
            }else if(error){
                console.log(error.body.message);
                this.showGenericErrorToast();
                this.closeModal();
            }
        }
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
    
    

    _linkReitek;//private var
    @api
    get linkReitek(){
        return this._linkReitek;
    }
    set linkReitek(value){
        this._linkReitek=value;
        if(value){
            this.enableConfirmButton();
        }
    }

    get indexZero(){//check if first page
        return this.scriptIndex==0;
    }

    get indexLast(){//check if last page
        return this.htmlScriptList.length == (this.scriptIndex+1);
    }

    prevSection(){
        this.scriptIndex-=1;
    }
    nextSection(){
        this.scriptIndex+=1;
    }

    get htmlScriptText(){
        let text;
        try{
            text=this.htmlScriptList[this.scriptIndex].sectionText;
        }
        catch(e){
            text=false;
        }
        return text;
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

    
    

    // async connectedCallback(){
    //     try{
    //         this.htmlScriptList=  await getHTMLScript({
    //             processName : this.scriptProcessName, 
    //             recordId : this.recordId, 
    //             childRecordIdentifier : this.childAdditionalInfo
    //         });
    //         if(this.htmlScriptList.length==0){
    //             this.showToast('error', 'Non è disponibile lo script per questa campagna!');
    //             this.closeModal();
    //         }else{
    //             console.log(this.htmlScriptList);
    //             console.log("ok deploy")
    //             this.scriptIndex=0;
    //         }

    //         //this.openModal=true;
    //     }catch(e){
    //         console.log(e.body.message);
    //         this.showGenericErrorToast();
    //         this.closeModal();
    //     }
    // }

    saveRecLink(){
        let link = this._linkReitek;
        saveReitekLink({recordId : this.recordId, activityId: this.activityId, reitekLink: link})
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    variant: "success",
                    title: "Link Salvato",
                    message: "L'operazione di salvataggio del link è andata a buon fine"
                }));
                this.confirm();
            }).catch(error => {
                console.log(error);
                this.showGenericErrorToast();
            })
    }

    enableConfirmButton(){
        let btConferma = this.template.querySelector('[data-id="scriptModalBt"]');
        if(btConferma){
            btConferma.disabled=false;
        }
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirmModal(){
        this.dispatchEvent(new CustomEvent('confirm'));
    }
}