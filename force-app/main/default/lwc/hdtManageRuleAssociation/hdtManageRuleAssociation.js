import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtManageRuleAssociation extends NavigationMixin(LightningElement) {

    @api recordid;
    configurationRuleObj;
    showWelcom = false;
    showSearchOffer = false;
    showCreateRecord = false;
    showSearchTable = false;
    template;
    showError = false;
    errorHeader = '';
    errorMessage = '';
    dmlContext;

    errorHeader = 'Associazione';
    errorMessage = '';

    label = {
        mainTitle: 'Associazione',
        associationTitleLabel: 'Associazione massiva della Product Rule',
        deleteTitleLabel: 'Rimozione massiva della Product Rule'
    };

    enableCreate = false;
    enableDelete = false;

    connectedCallback(){
        console.log('>>> RULE Id: ' + this.recordid);
        this.enableCreate = true;
        this.enableDelete = true;
        this.showWelcom = true;
    }

    //@wire(getRecord, { recordId: '$recordid', fields: ['Product2.Family', 'Product2.Status__c'] })
    //wiredProduct({ error, data }) {
    //    if (data) {

    //    } else if (error) {
    //        for(var key in error){
    //            console.log('# Error -> ' + key + ' - ' + error[key]);
    //        }
    //    }
    //}

    handleClick(event){
        console.log('### recordid -> ' + this.recordid);
    }

    closeModal(event){
        console.log('### Parent closeModal ###');
        console.log('### return to-> ' + this.recordid);

        const goback = new CustomEvent('goback', {
            detail: {prodId: this.recordid}
        });
        // Fire the custom event
        this.dispatchEvent(goback);
        this.goToRecord(this.recordid, 'Product2');

    }

    createAssociation(event){
        console.log('### Parent createAssociation ###');
        this.dmlContext = 'insert';
        this.showWelcom = false;
        this.showCreateRecord = true;
    }

    deleteAssociation(event){
        console.log('### Parent deleteAssociation ###');
        this.dmlContext = 'delete';
        this.showWelcom = false;
        //this.showCreateRecord = true;
        this.showSearchTable = true;
    }

    closeSearch(event){
        this.showWelcom = true;
        this.showSearchOffer = false;
        
        console.log('### return to-> ' + this.recordid);
        this.goToRecord(this.recordid, 'Product2');

    }

    saveRecord(event){        
        console.log('>>> RECORD CONFIGURED -> ' + event.detail.configurationRuleObj);
        this.configurationRuleObj = event.detail.configurationRuleObj;
        this.showCreateRecord = false;
        this.showSearchTable = true;
    }

    closeEditForm(event){
        this.showCreateRecord = false;
        this.showWelcom = true;
    }

    goToRecord(recId, objName){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        });
    }

}