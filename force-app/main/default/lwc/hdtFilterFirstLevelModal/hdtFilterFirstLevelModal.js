import { LightningElement, track, api } from "lwc";

export default class HdtFilterFirstLevelModal extends LightningElement {
  
    @api columns;
    @api modalTitle;
    @api confirmLabel;
    @track filterObj = [];
    error;

    setOperator(event){
        let foundRow = this.filterObj.find(ele  => ele.fieldName === event.detail.fieldName);
        if(foundRow === undefined){
            this.filterObj.push({fieldName: event.detail.fieldName, operator: event.detail.operator});
        } else {
            foundRow.operator = event.detail.operator;
        }
        //console.log(JSON.stringify(this.filterObj));
    }

    onChangeHandler(event){

        let foundRow = this.filterObj.find(ele  => ele.fieldName === event.currentTarget.name);
        var valueToSet;

        if(event.currentTarget.type == 'checkbox'){
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
            .filter(element => element.checked)
            .map(element => element.name);
    
            valueToSet = (checked.filter(c => { return c ==  event.currentTarget.name})[0] != undefined) ? true : false;

        } else {
            valueToSet = event.detail.value;
        }

        if(foundRow === undefined){
            this.filterObj.push({fieldName: event.currentTarget.name, value: valueToSet});
        } else {
            foundRow.value = valueToSet;
        }

        //console.log(JSON.stringify(this.filterObj));
    }

    applyFilter(){
        var interObj = {};
        this.filterObj.forEach((element) => {
            for (var key in element) {
                if(element[key] === undefined || element[key] ===''){
                    break;
                }
                interObj[element.fieldName] = {operator: element.operator, value: element.value};
            }            
        });

        var filterObj = JSON.stringify(interObj);

        console.log('>>> ' + filterObj);

        const sendApply = new CustomEvent("applyinterrogation", {
            detail: {value: filterObj}
        });
        // Dispatches the event.
        this.dispatchEvent(sendApply);
        this.resetParameters();
    }

    closeModal(){
        console.log('>>> close');
        this.closeModalEvent();
        this.resetParameters();
    }

    closeModalEvent(){
        const closeModal = new CustomEvent("closemodal", {
            detail: {booleanVar: 'showFilterFirstLevel'}
        });
        // Dispatches the event.
        this.dispatchEvent(closeModal); 
    }

    resetParameters(){
        this.filterObj = [];
    }

}