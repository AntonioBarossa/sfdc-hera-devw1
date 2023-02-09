import { LightningElement, api } from 'lwc';

export default class HdtFlowRunner extends LightningElement {
    @api flowApiName;
    @api inputVariables;
    _destroy = false;

    get showFlow(){
        return flowApiName && !_destroy;
    }

    handleStatusChange(event){
        console.log("statuschange");
        this.dispatchEvent(new CustomEvent("changeEvent", {detail : event.detail}));
    }

    @api destroy(){
        this._destroy=true;
        return;
    }
}