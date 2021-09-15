import { LightningElement, track, api } from "lwc";

export default class HdtFilterFirstLevelModal extends LightningElement {
  
    @api columns;
    @api modalTitle;
    @api confirmLabel;
    @api firstLevelFilterObj;
    @track filterObj = [];
    defaultFilterObj = [];
    error;

    connectedCallback(){
        console.log('>>> INPUT FILTER OBJ ' + JSON.stringify(this.firstLevelFilterObj));

        this.columns.forEach((element) => {
            if(element.isFilter){
                var tempObj = {};
                tempObj.label = element.label;
                tempObj.fieldName = element.fieldName;
                tempObj.type = element.detail.type;
                tempObj.filterDetail = {};

                if(this.firstLevelFilterObj != undefined && this.firstLevelFilterObj[element.fieldName] != undefined){
                    tempObj.filterDetail.operator = this.firstLevelFilterObj[element.fieldName].operator;
                    tempObj.filterDetail.value = this.firstLevelFilterObj[element.fieldName].value;
                    this.filterObj.push({fieldName: element.fieldName, operator: tempObj.filterDetail.operator, value: tempObj.filterDetail.value});
                } else {
                    tempObj.filterDetail.operator = null;
                    tempObj.filterDetail.value = '';                
                }

                this.defaultFilterObj.push(tempObj);
            }
        });

        console.log('>>> INNER FILTER OBJ ' + JSON.stringify(this.filterObj));
        //console.log('>>> NEW COLUMNS ' + JSON.stringify(this.defaultFilterObj));

    }

    setOperator(event){
        console.log('>>> operator ' + event.detail.operator);

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

    checkSingleField(field){
        if(field === undefined || field === null || field === ''){
            return false;
        } else {
            return true;
        }
    }

    applyFilter(){
        console.log('>>> INNER FILTER OBJ ' + JSON.stringify(this.filterObj));
        try {
            var interObj = {};
            this.filterObj.forEach((element) => {
                if(this.checkSingleField(element.fieldName) && this.checkSingleField(element.operator) && this.checkSingleField(element.value)){
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
            //this.resetParameters();

        } catch (error) {
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );            
        }
    }

    closeModal(){
        console.log('>>> close HdtFilterFirstLevelModal');
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