import getScriptPage from '@salesforce/apex/HDT_LC_DecisionalScriptController.getScriptPage';
import saveReitekLink from '@salesforce/apex/HDT_LC_HdtScriptManagementModal.saveReitekLink';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, wire } from 'lwc';

export default class HdtManageScriptDecisionalCard extends LightningElement {

    @api scriptProcessName;//Script Process
    @api recordId;//record starting Object
    @api activityId;
    @api childAdditionalInfo="";//API field of child Record you want to show info in the title

    isLoading = false;
    scriptPage;
    historyIndex = 0;
    pageHistory = [1];
    
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

    get hasPrevious(){
        return (this.historyIndex>0);
    }

    get hasNext(){
        return (this.historyIndex<(this.pageHistory.length-1)) || (this.scriptPage.nextSection!=null);
    }

    get isLastPage(){
        return (this.scriptPage!=null && this.scriptPage.decisions.length==0) &&
            this.historyIndex==(this.pageHistory.length-1) && 
            this.scriptPage.nextSection==null;
    }

    prevSection(){
        this.historyIndex-=1;
        this.loadScriptPage();
    }

    nextSection(){
        if (this.scriptPage.nextSection) {
            this.pageHistory.push(this.scriptPage.nextSection);
        }

        this.historyIndex+=1;
        this.loadScriptPage();
    }

    goToNextPage(event){
        let nextPageIndex = event.target.value;

        if (this.historyIndex<(this.pageHistory.length-1)) {
            this.pageHistory.splice(this.historyIndex+1);
        }

        this.pageHistory.push(nextPageIndex);
        this.historyIndex++;
        this.loadScriptPage();
    }

    connectedCallback(){
        this.loadScriptPage();
    }

    loadScriptPage() {
        this.isLoading = true;
        console.log("loadScriptPage", this.recordId);
        return getScriptPage({
            processName : this.scriptProcessName, 
            recordId : this.recordId, 
            pageIndex : this.pageHistory[ this.historyIndex ]
        }).then(page => {
            console.log("scriptPage", JSON.stringify(page));
            if(page){
                if (page.sectionText) {
                    this.scriptPage = page;
                    this.isLoading = false;
                }
                else {
                    this.pageHistory[ this.pageHistory.length-1 ] = page.nextSection;
                    this.loadScriptPage();
                }
            }else{
                this.showToast('error', 'Non è disponibile lo script per questa campagna!');
                this.closeModal();
            }
            
        },error => {
            console.log(error.body.message);
            this.showGenericErrorToast();
        });
    }

    saveRecLink(){
        this.isLoading = true;
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
            }).then(() => {
                this.isLoading = false;
            })
    }

    closeModal(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    confirm(){
        this.dispatchEvent(new CustomEvent('confirm'));
    }

    enableConfirmButton(){
        let btConferma = this.template.querySelector('[data-id="scriptModalBt"]');
        if(btConferma){
            btConferma.disabled=false;
        }
    }
}