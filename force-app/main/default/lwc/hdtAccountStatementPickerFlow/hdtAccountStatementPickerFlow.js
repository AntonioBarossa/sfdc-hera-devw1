import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class HdtAccountStatementPickerFlow extends LightningElement {
    @api contractAccount;
    @api billingProfileId;
    @api codiceCliente;
    @api caseId;
    @api processType;
    @api accountId;

    @api availableActions = [];
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
	@api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;

    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    handleNext() {
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }
}