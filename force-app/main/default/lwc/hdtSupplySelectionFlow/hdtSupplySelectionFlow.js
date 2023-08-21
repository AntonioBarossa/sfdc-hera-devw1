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

        this.selectedServicePointFlow = event.detail["ServicePointId"];
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
        //console.log('handleConfirmServicePoint: event.detail["ServicePointId"] '+ event.detail["ServicePointId"]);
        var spId = event.detail["ServicePointId"] === undefined ? event.detail["Id"] : event.detail["ServicePointId"];
        if(spId != null && spId != undefined && spId != ''){
            this.selectedServicePointFlow = spId;
        }
        this.handleSave(event);
    }

    /*handleNewServicePoint(event)
    {
        console.log('# NewServicePoint: ' + JSON.stringify(event.detail))
        const spId = event.detail["newServicePoint"].Id;
        console.log('# NewServicePointId: ' + spId);
        this.selectedServicePointFlow = spId;
    }*/

    handleSave(event){
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    handleCancell(event){
        this.cancelCase = true;
        this.handleSave();
    }
}