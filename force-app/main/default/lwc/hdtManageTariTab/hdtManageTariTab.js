import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllManageableTab from '@salesforce/apex/HDT_UTL_ManageTariTab.getAllManageableTab';


export default class HdtManageTariTab extends NavigationMixin(LightningElement) {
    manageableTable;
    options;
    label = 'Vai';
    selectedValue;
    isButtonDisabled = true;

    connectedCallback(){
        this.getAllTab();
    }

    async getAllTab(){
        this.manageableTable = await getAllManageableTab();
        console.log('init ->' + this.manageableTable);
        this.options = [];

            console.log('result --> '+JSON.stringify(this.manageableTable));
            var conts = this.manageableTable;
            for(var key in conts){
                console.log('conts[key] --> '+conts[key]);
                console.log('key --> '+key);
                const option = {
                    label: conts[key],
                    value: key
                };
                
                if(this.options != undefined){
                    this.options = [...this.options, option];
                }
                else{
                    this.options = [option];
                }

            }
            console.log('this.options --> '+JSON.stringify(this.options));
    }


    handleChange(event) {
        this.selectedValue = event.detail.value;
        if(this.isButtonDisabled) this.isButtonDisabled = false;
    }
    
    navigateToTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.selectedValue,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}