import { LightningElement, track } from 'lwc';
import getRecords from  '@salesforce/apex/HDT_LC_OfferConfiguratorController.getTechnicalOfferRecords';
import cloneRecord from  '@salesforce/apex/HDT_LC_OfferConfiguratorController.cloneRecord';

const columns = [
    { label: 'Definizione', fieldName: 'definition' },
    { label: 'Ins.Utente', fieldName: 'checkUser'},
    { label: 'Tariffa', fieldName: 'amount'},
    { label: 'GR Info', fieldName: 'grInfo'},
    { label: 'Prezzo', fieldName: 'price'},
    { label: 'Sconto', fieldName: 'discount' },
    { label: 'Valore', fieldName: 'value'},
    { label: 'Stringa', fieldName: 'stringValue'},
    { label: 'Nome Tecn.', fieldName: 'tecName'}   
];

export default class HdtSearchTechnicalOffer extends LightningElement {
    data = [];
    columns = columns;
    detailFields = ['Version__c', 'OffertCode__c'];
    showTable = false;

    @track result = {show: false, message: ''};
    @track error = {show: false, message: ''};

    @track item = {
        selectedId: '',
        name: '',
        code: ''
    }

    @track selid;
    @track selectRecordName;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    @track searchObj = {
        offertName: '',
        version: '',
        offertCode: ''
    }

    /*setOffertName(event){
        console.log('### setOffertName ###');
        this.searchObj.offertName = event.target.value;
    }

    setVersion(event){
        console.log('### setVersion ###');
        this.searchObj.version = event.target.value;
    }

    setOffertCode(event){
        console.log('### setOffertCode ###');
        this.searchObj.offertCode = event.target.value;
    }*/

    searchClick(event){
        console.log('### searchClick ###');
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'loadingdata slds-text-heading_small';
        this.handleSearch(this.item.selectedId);
    }

    handleSearch(recId){
        console.log('# handleSearch #');

        getRecords({recordId: recId})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');
                    var obj = JSON.parse(result);
                    this.data = obj.offerData;

                    if(this.data.length===0){
                        this.result.show = true;
                        this.showTable = false;
                        this.result.message = 'Non è stato trovato nessuna configurazione';
                    }

                    this.spinnerObj.spinner = false;
                    this.showTable = true;
                } else {
                    this.error.show = true;
                    this.error.message = 'An error occurred!';
                    this.spinnerObj.spinner = false;
                }
               
            }).catch(error => {
                this.error.show = true;
                this.error.message = error.body.message;
                this.spinnerObj.spinner = false;
            });
    }

    cloneData(event){
        console.log('### cloneData ###');
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';
        this.handleClone(this.item.selectedId);
        
        setTimeout(() => {

        }, 2000);
        
    }

    handleClone(recId){
        console.log('# handleClone #');
 
        cloneRecord({recordId: recId})
            .then(result => {
                console.log('# call result #');

                if(result){
                    console.log('# success #');
                } else {
                    this.error.show = true;
                    this.error.message = 'An error occurred!';
                }
                this.spinnerObj.spinner = false;
            }).catch(error => {
                this.error.show = true;
                this.error.message = error.body.message;
                this.spinnerObj.spinner = false;
            });
    }

    closeSearch(event){
        console.log('### closeSearch ###');
        this.searchObj.offertName = '';
        this.searchObj.version = '';
        this.searchObj.offertCode = '';
        const goback = new CustomEvent("goback", {
            detail:  {prodId: this.productid}
        });

        // Dispatches the event.
        this.dispatchEvent(goback);
    }

    handleSelection(event){
        console.log('# handleSelection #');
        console.log('# set -> ' + event.detail.selectedId + ' - ' + event.detail.code + '- ' + event.detail.selectedObj);
        this.item.selectedId = event.detail.selectedId;
        this.item.name = event.detail.code;
        this.item.code = event.detail.selectedObj;
    }

    back(event){
        this.error.show = false;
    }
}
