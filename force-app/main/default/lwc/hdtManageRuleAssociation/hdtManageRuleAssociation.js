import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import cl_CreateTitle from '@salesforce/label/c.ConfRuleCreateTitle';
import cl_DeleteTitle from '@salesforce/label/c.ConfRuleDeleteTitle';
import cl_DeleteSection from '@salesforce/label/c.ConfRuleDeleteSection';
import cl_CreateSection from '@salesforce/label/c.ConfRuleCreateSection';
import cl_ConfirmSelection from '@salesforce/label/c.ProdOptAssociationConfirmSelection';
import cl_Close from '@salesforce/label/c.ProdOptAssociationClose';
import cl_CloseDeleteBody from '@salesforce/label/c.ConfRuleCloseDeleteBody';
import cl_CloseCreateBody from '@salesforce/label/c.ConfRuleCloseCreateBody';
import cl_ConfimSelectBody from '@salesforce/label/c.ConfRuleConfimSelectBody';
import cl_ConfirmFilterTitle from '@salesforce/label/c.ProdOptAssociationConfirmFilterTitle';
import cl_ConfirmFilterDeleteBody from '@salesforce/label/c.ConfRuleConfirmFilterDeleteBody';
import cl_ConfirmFilterCreateBody from '@salesforce/label/c.ConfRuleConfirmFilterCreateBody';
import cl_ConfimSelectBodyDelete from '@salesforce/label/c.ConfRuleConfimSelectBodyDelete';
import cl_ResultText from '@salesforce/label/c.ProdOptAssociationResultText';
import cl_NoResultText from '@salesforce/label/c.ProdOptAssociationNoResultText';

export default class HdtManageRuleAssociation extends NavigationMixin(LightningElement) {

    tableLabels = {
        cl_CreateTitle,
        cl_DeleteTitle,
        cl_DeleteSection,
        cl_CreateSection,
        cl_ConfirmSelection,
        cl_Close,
        cl_CloseDeleteBody,
        cl_CloseCreateBody,
        cl_ConfimSelectBody,
        cl_ConfirmFilterTitle,
        cl_ConfirmFilterDeleteBody,
        cl_ConfirmFilterCreateBody,
        cl_ConfimSelectBodyDelete,
        cl_ResultText,
        cl_NoResultText
    };

    @api recordid;
    objApiName = 'SBQQ__ConfigurationRule__c';
    recordData;
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
        //this.enableCreate = true;
        //this.enableDelete = true;
        //this.showWelcom = true;
    }

    @wire(getRecord, { recordId: '$recordid', fields: ['SBQQ__ProductRule__c.Name'] })
    wiredProduct({ error, data }) {
        if (data) {

            this.recordData = data;

            this.enableCreate = true;
            this.enableDelete = true;
            this.showWelcom = true;

        } else if (error) {
            for(var key in error){
                console.log('# Error -> ' + key + ' - ' + JSON.stringify(error[key]));
            }
        }
    }

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