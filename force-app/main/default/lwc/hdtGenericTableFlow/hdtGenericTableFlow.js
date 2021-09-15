import { api, LightningElement } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class HdtGenericTableFlow extends LightningElement {

//Flow Inputs
    //buttons
    @api availableActions = [];
    @api saveButton;
    @api disabledSaveButton = false;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
	@api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelCancelButton;
//Flow Outputs
    @api draft = false;
    @api cancel = false;
    @api recordId;
    @api objName;
    //utilities
    @api tableName;
    @api searchKey;
    @api searchTerm;
    @api maxRowSelect;

    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    handleNext(event) {
        console.log('Inside Event -> ' + event.currentTarget.name);
        if(event.currentTarget.name === 'draft'){
            this.draft = true;
            this.cancel = false;
        } else if(event.currentTarget.name === 'cancel'){
            this.cancel = true;
            this.draft = false;
        }
        console.log('checks done');
        if(this.availableActions.find(action => action === 'NEXT')){
            console.log('Inside Next Event');    
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            console.log('Inside Finish Event');
            const navigateFinish = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinish);
        }
    }
    onSelectedRow(event){
        console.log('SelectedId' + event.detail[0]["_id"]);
        this.recordId = event.detail[0]["_id"];
        this.objName  = event.detail[0]["_objName"];
    }
    disableButton(event){
        this.disabledSaveButton = true;
    }
}