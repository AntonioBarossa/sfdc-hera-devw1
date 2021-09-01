import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class HdtSupplySelectionFlow extends LightningElement {

    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    @api selectedServicePointFlow;
    @api saveButton;
    @api cancelButton;
    @api labelSaveButton;
    @api cancelCase;
    @api isCompatible;
    @api serviceRequestId;

    cancelDisabled = true;

    handleServicePointSelection(event){
        this.selectedServicePointFlow = event.detail["Codice Punto"];
        this.serviceRequestId = event.detail["serviceRequestId"];
        this.isCompatible = event.detail["isCompatible"];
        console.log('isCompatibile ' + this.isCompatible);
        if(this.isCompatible === false)
        {
            this.cancelDisabled = false;
        }
        console.log('forn '+ this.selectedServicePointFlow);
    }

    handleConfirmServicePoint(event){
        console.log('forn '+ this.selectedServicePointFlow);
        this.handleSave(event);
    }
    handleSave(event){

        const navigateNextEvent = new FlowNavigationNextEvent();

        this.dispatchEvent(navigateNextEvent);

    }
    handleCancell(event){

        this.cancelCase = true;

        this.handleSave();
        
    }
}