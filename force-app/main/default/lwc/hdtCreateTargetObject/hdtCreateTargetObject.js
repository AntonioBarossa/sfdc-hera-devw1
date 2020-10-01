import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class hdtCreateTargetObject extends NavigationMixin(LightningElement) {
    @api accountid;
    @api targetobject;
    showModal = false;
    recordType = '';
    
    openModal(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }

    get recordTypeOptions(){
        return [
            { label: 'Sales', value: 'option1' },
            { label: 'Force', value: 'option2' },
        ];
    }

    handleRecordTypeSelection(){

    }

    goToServiceCreateForm(){

    }
}