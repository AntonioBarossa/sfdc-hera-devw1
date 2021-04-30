import { LightningElement, track, api } from 'lwc';

const filterObject = {};

export default class HdtDetailFilterModal extends LightningElement {

    @track filterObject = filterObject;
    @api consider;
    @api fieldsToFilter;
    
    connectedCallback(){
        if(!this.consider){
            for (var key in this.fieldsToFilter) {
                this.filterObject[this.fieldsToFilter[key].fieldName] = '';
            }          
        }
    }

    closeModal() {
        console.log('# closeModal #');
        if(!this.consider){
            for (var key in this.filterObject) {
                this.filterObject[key] = '';
            }
        }
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
    }

}