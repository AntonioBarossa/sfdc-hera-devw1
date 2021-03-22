import { LightningElement, track, api, wire } from 'lwc';
import getTabsMetaData from '@salesforce/apex/HDT_LC_AccountStatementController.getTabsMetaData';

/*const tabList = [
    {label: 'Estratto conto', value: 'EC', isDeveloped: true},
    {label: 'Gestione del credito', value: 'EC1', isDeveloped: true},
    {label: 'Scaduto per riattivazione', value: 'EC9', isDeveloped: true},
    {label: 'Paperless', value: 'paperless', isDeveloped: true},
    {label: 'Rate', value: 'EC4', isDeveloped: true},
    {label: 'Solleciti', value: 'EC6', isDeveloped: true},
    {label: 'Parite non fatturate', value: 'EC7', isDeveloped: true},
    {label: 'Pagamenti e compensazioni', value: 'EC5', isDeveloped: true},
    {label: 'Indennizzi', value: 'EC8', isDeveloped: true},
    {label: 'Note Var. IVA', value: 'npi', isDeveloped: true},
];*/

export default class HdtAccountStatementTabs extends LightningElement {
    @api recordId;
    @track tabContent = '';
    @track statementType;
    @track tabList;
    @track defaultTab = 'EC';
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    //currentTab = '';
    previousTab = '';

    connectedCallback(){
        this.getTabsMetaData();
        this.statementType = 'ORDINARIO';
        //this.tabList = tabList;
    }

    getTabsMetaData(){
        getTabsMetaData()
        .then(result => {
            console.log('# # #');

            if(result.success){
                console.log('>>> result > ' + result.success);
                this.tabList = result.tabDetail;
            } else {
                console.log('# error #');
            }

        })
        .catch(error => {

        });
    }

    openSpinner(){
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = '';         
    }

    removeSpinner(){
        this.spinnerObj.spinner = false;
        this.spinnerObj.spincss = '';        
    }

    handleActive(event) {

        console.log('# LWC -> ' + event.target.value + ' # is now active');

        if(this.previousTab != null && this.previousTab != ''){
            //delete lwc data
            console.log('# delete data  to -> ' + this.previousTab);
            
            try{
                //this.template.querySelector(this.previousTab).cancelData();
                this.template.querySelectorAll('[data-tabcode="' + this.previousTab + '"]').forEach((tab) => {
                    if(tab.dataset.tabcode === this.previousTab){
                        tab.cancelData();
                    }
                });
            } catch (error){
                console.warn('# No LWC found #');
            }

            //var isLoaded;
            try{
                //isLoaded = this.template.querySelector(event.target.value).isLoaded;
                this.template.querySelectorAll('[data-tabcode="' + event.target.value + '"]').forEach((tab) => {
                    if(tab.dataset.tabcode === event.target.value){
                        //isLoaded = tab.isLoaded;
                        if(tab.isLoaded){
                            tab.reopenTab();
                        }
                    }
                });
            } catch (error){
                console.error('# ERROR TO RELOAD LWC #');
                console.error('e.name => ' + error.name );
                console.error('e.message => ' + error.message);
                console.error('e.stack => ' + error.stack);
            }

            //console.log('# isLoaded: ' + isLoaded);

           //+if(isLoaded){
           //+    //this.template.querySelector(event.target.value).reopenTab();
           //+    this.template.querySelectorAll('[data-tabcode="' + event.target.value + '"]').forEach((tab) => {
           //+        if(tab.dataset.tabcode === event.target.value){
           //+            tab.reopenTab();
           //+        }
           //+    });
           //+}
        }

        this.previousTab = event.target.value;

    }

    setStatementType(event){
        this.statementType = event.detail;
    }

}