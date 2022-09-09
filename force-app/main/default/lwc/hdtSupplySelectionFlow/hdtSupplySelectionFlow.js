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
    saveDisabled = true;

    handleServicePointSelection(event){

        this.selectedServicePointFlow = event.detail["Codice Punto"];
        this.serviceRequestId = event.detail["serviceRequestId"];
        this.isCompatible = event.detail["isCompatible"];

        if(this.isCompatible === false){
            this.cancelDisabled = false;
            this.cancelCase = true;
        }
        else if(this.isCompatible === true){
            this.saveDisabled = false;
        }
    }

    handleConfirmServicePoint(event){
        console.log('handleConfirmServicePoint '+ JSON.stringify(event.detail));
        var spCode = event.detail["ServicePointCode__c"];
        if(spCode != null && spCode != undefined && spCode != ''){
            this.selectedServicePointFlow = event.detail["ServicePointCode__c"];
        }
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