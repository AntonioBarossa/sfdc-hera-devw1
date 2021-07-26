import { api, LightningElement } from 'lwc';

export default class HdtGenericTableFlow extends LightningElement {

//Flow Inputs
    //buttons
    @api availableActions = [];
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
	@api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelCancelButton;
    @api draft = false;
    @api cancel = false;
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
        if(event.target.name === 'draft'){
            this.draft = true;
        } else if(event.target.name == 'cancel'){
            this.cancel = true;
        }
        if(this.availableActions.find(action => action === 'NEXT')){    
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            const navigateFinish = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinish);
        }
    }
}