import getScriptPage from '@salesforce/apex/HDT_LC_DecisionalScriptController.getScriptPage';
import saveReitekLink from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.saveReitekLink';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, wire } from 'lwc';

export default class HdtManageScriptDecisionalCard extends LightningElement {

    @api scriptProcessName;//Script Process
    @api recordId;//record starting Object
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title

    scriptPage;
    pageIndex = 1;
    historyIndex = 0;
    pageHistory = [];
    
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

    get hasDecisions(){
        return (this.scriptPage!=null && this.scriptPage.decisions.length>0);
    }

    get hasPrevious(){//check if first page
        return this.pageIndex==0;
    }

    get hasNext(){//check if last page
        return this.htmlScriptList.length == (this.pageIndex+1);
    }

    prevSection(){
        this.pageIndex-=1;
        this.loadScriptPage();
    }

    nextSection(){
        this.pageIndex+=1;
        this.loadScriptPage();
    }

    connectedCallback(){
        this.loadScriptPage();
    }

    loadScriptPage() {
        return getScriptPage({
            processName : this.scriptProcessName, 
            recordId : this.recordId, 
            pageIndex : this.pageIndex
        }).then(page => {
            console.log("scriptPage", JSON.stringify(page));
            this.scriptPage = page;
        },error => {
            console.log(error.body.message);
            this.showGenericErrorToast();
        });
    }

    saveRecLink(){
        let link= this._linkReitek;
        saveReitekLink({recordId : this.recordId, reitekLink: link})
            .then(result=>{
                this.dispatchEvent(new ShowToastEvent({
                    variant: "success",
                    title: "Link Salvato",
                    message: "L'operazione di salvataggio del link è andata a buon fine"
                }));
                this.closeModal();
            }).catch(error=>{
                console.log(error);
                this.showGenericErrorToast();
            });
        
    }

    enableConfirmButton(){
        let btConferma = this.template.querySelector('[data-id="scriptModalBt"]');
        if(btConferma){
            btConferma.disabled=false;
        }
    }
}