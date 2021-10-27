import { LightningElement, api } from 'lwc';
import getAsyncApexJob from '@salesforce/apex/HDT_LC_ProductAssociation.getAsyncApexJob';

import chooseAssOperation_JobIsRunning from '@salesforce/label/c.ChooseAssOperation_JobIsRunning';
import chooseAssOperation_CreateIsAvailable from '@salesforce/label/c.ChooseAssOperation_CreateIsAvailable';
import chooseAssOperation_DeleteIsAvailable from '@salesforce/label/c.ChooseAssOperation_DeleteIsAvailable';
import chooseAssOperation_StatusError from '@salesforce/label/c.ChooseAssOperation_StatusError';

export default class HdtChooseAssociationOperation extends LightningElement {

    @api objType;
    @api iconName;
    @api mainTitleLabel;
    @api deleteTitleLabel;
    @api associationTitleLabel;
    @api enableCreate;
    @api enableDelete;
    asyncApexJobIsRun = false;
    createAssociationClass = 'slds-box slds-box_link slds-media isDisabled';
    deleteAssociationClass = 'slds-box slds-box_link slds-media isDisabled';
    createAssociationTitle;
    deleteAssociationTitle;

    connectedCallback(){
        this.getAsyncApexJob();
    }

    getAsyncApexJob(){
        getAsyncApexJob({objType: this.objType})
        .then(result => {
            console.log('>>> getAsyncApexJob');
            console.log('>>> ' + JSON.stringify(result));

            if(result > 0){
                this.asyncApexJobIsRun = true;
                this.createAssociationTitle = chooseAssOperation_JobIsRunning;
                this.deleteAssociationTitle = chooseAssOperation_JobIsRunning;
            } else {
                this.enableDisableOperation();
            }
            
        })
        .catch(error => {
            console.log('# getAsyncApexJob #');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while retriving AsyncApexJob',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    enableDisableOperation(){
        this.createAssociationClass = (this.enableCreate) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
        this.deleteAssociationClass = (this.enableDelete) ? 'slds-box slds-box_link slds-media' : 'slds-box slds-box_link slds-media isDisabled';
        this.createAssociationTitle = (this.enableCreate) ? chooseAssOperation_CreateIsAvailable : chooseAssOperation_StatusError;
        this.deleteAssociationTitle = (this.enableDelete) ? chooseAssOperation_DeleteIsAvailable : chooseAssOperation_StatusError;
    }

    closeModal(event){
        console.log('### closeModal ###');
        const closeEvent = new CustomEvent("closemodal", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    createAssociation(event){
        console.log('### createAssociation ###');
        if(this.enableCreate && !this.asyncApexJobIsRun){
            const searchEvent = new CustomEvent("createassociation", {
                detail:  ''
            });
    
            // Dispatches the event.
            this.dispatchEvent(searchEvent); 
        }
    }

    onDelete(event){
        console.log('### createNew ###');
        if(this.enableDelete && !this.asyncApexJobIsRun){
            const createnewEvent = new CustomEvent("deleteassociation", {
                detail:  ''
            });

            // Dispatches the event.
            this.dispatchEvent(createnewEvent);
        }
    }

}