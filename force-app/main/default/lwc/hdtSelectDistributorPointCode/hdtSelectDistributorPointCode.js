import { LightningElement, api, track } from 'lwc';

export default class HdtSelectDistributorPointCode extends LightningElement {
    
    disableCheckBoxDistributor=false;
    openFormDistributor=false;
    @api objectApiName;
    @api retrieveddistributor;
    pagesDistributor = [];
    originalData = [];
    @track currentPage = 1;
    totalPageDistributor = 0;
    preloading = false;
    tableDataDistributor=[];
    rowToSend;
    @track currentPageDistributor = 1;


    columnsDistributor = [
        { label: 'Distributore', fieldName: 'Distributor', type: 'text',
        cellAttributes: 
        { class: 'slds-text-color_default slds-text-title_caps'} }
    ];


    get getCurrentPageDistributor(){
        if (this.totalPageDistributor ===0) return 0;
        return this.currentPageDistributor;
    }

    @api
    handleConfirmDistributor(){
        this.dispatchEvent(new CustomEvent('distributorselected', {detail: this.rowToSend}));
        this.closeDistributorForm();
    }


    @api
    nextPageDistributor(){
        if (this.currentPageDistributor < this.totalPageDistributor)
        {this.currentPageDistributor++;
            this.reLoadTableDistributor();
        }
    }

    @api
    previousPageDistributor(){
        if (this.currentPageDistributor > 1) {
            this.currentPageDistributor--;
            this.reLoadTableDistributor();
        }
    }

    @api
    connectedCallback(){
        console.log('connectedCallback START');
        console.log('retrieveddistributor : ' + JSON.stringify(this.retrieveddistributor));
        let distributors=[];
        this.disableCheckBoxDistributor=true;
        this.openFormDistributor=true;

        this.retrieveddistributor.forEach(element=>{
            if(element.Account__c === undefined || element.Account__r.Name === undefined) return;
            console.log('element ---- : ' + JSON.stringify(element));
            
            console.log('element ---- : ' + JSON.stringify(element.Account__r.Name));
            
            distributors.push({'Distributor': element.Account__r.Name});  

            
           
        });
        this.createTableDistributor(distributors);
        console.log('connectedCallback END');
    }


    @api
    closeDistributorForm(){
        console.log('closeDistributorForm START');
        
        this.openFormDistributor=false;
        this.dispatchEvent(new CustomEvent('closedform', {detail: false}));
        console.log('closeDistributorForm END');
    }


    createTableDistributor(data) {
        console.log('createTableDistributor   data --- : ' + JSON.stringify(data));
        let i=0;
        this.tableDataDistributor = data.slice(i, data.length);
        // let i, j, temporary, chunk = 10;
        // this.pagesDistributor = [];
        // for (i = 0, j = data.length; i < j; i += chunk) {
        //     temporary = data.slice(i, i + chunk);
        //     this.pagesDistributor.push(temporary);
        // }
        // this.totalPageDistributor = this.pagesDistributor.length;
        //this.reLoadTableDistributor();
    }

    reLoadTableDistributor() {
        // this.tableDataComune = [];
         this.tableDataDistributor = this.pagesDistributor[this.currentPageDistributor - 1];
     
         console.log('tableData********'+ JSON.stringify(this.tableDataDistributor));
     
     }



     getDistributor(event){
        
        let selectedRows = event.detail.selectedRows;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
     }
}