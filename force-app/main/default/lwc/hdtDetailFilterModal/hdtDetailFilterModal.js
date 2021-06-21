import { LightningElement, track, api } from 'lwc';

const filterObject = {};

export default class HdtDetailFilterModal extends LightningElement {

    @api fieldsToFilter;
    @track columns = [];
    @track title = 'Interrogazione';
    @track filterLabel = 'interroga';

    connectedCallback(){

        this.fieldsToFilter.forEach((element) => {
            var obj = {fieldName: element.fieldName, label: element.label, detail: {type: element.type}};
            this.columns.push(obj);
        });
    }

    applyInterFromChild(event){
        var filterObj = event.detail.value;
        const applyInt = new CustomEvent("setobjfilter", {
            detail: {value: filterObj}
        });
        // Dispatches the event.
        this.dispatchEvent(applyInt); 
    }

    closeModalHandler(){
        console.log('# closeModal #');
        const closeModal = new CustomEvent("closemodal", {
            detail:  {action: ''}
        });
        // Dispatches the event.
        this.dispatchEvent(closeModal); 
    }

    /*@track filterObject = filterObject;
    @api consider;
    @api fieldsToFilter;
    
    connectedCallback(){

        //if(!this.consider){
        //    for (var key in this.fieldsToFilter) {
        //        this.filterObject[this.fieldsToFilter[key].fieldName] = '';
        //    }          
        //}
    }

    closeModal() {
        console.log('# closeModal #');
        //if(!this.consider){
        //    for (var key in this.filterObject) {
        //        this.filterObject[key] = '';
        //    }
        //}
        const closeModal = new CustomEvent("closemodal", {
            detail:  {action: ''}
        });
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }

    setFilterParam(event){
        var fieldId = event.target.id.split('-')[0];
        this.filterObject[fieldId] = event.target.value;
    }

    applyFilter(){
        console.log('# applyFilter #');
        const selectedObj = new CustomEvent("setobjfilter", {
            detail:  {
                filterobj: JSON.stringify(this.filterObject)
                //servizio: this.filterObject.servizio,
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedObj);
    }*/

}