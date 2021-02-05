import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProducts from '@salesforce/apex/AvailableProductsController.getProducts';
import insertUpdateOrderProducts from '@salesforce/apex/AvailableProductsController.insertUpdateOrderProducts';
//import activateOrder from '@salesforce/apex/AvailableProductsController.activateOrder';

import{CurrentPageReference}
      from 'lightning/navigation';
      import { fireEvent } from 'c/pubSub';

const columns = [{
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'List Price',
        fieldName: 'UnitPrice',
        sortable: true
    }
   
];

export default class AvailableProducts extends LightningElement {
    @wire(CurrentPageReference) pageRef
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    @api recordId;
    result;
    
    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 10; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track displayError = false;
    errorSelect='Select any Product';
    @wire(getProducts, {searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection'})
    wiredAccounts({ error, data }) {
        if (data) {
        
            this.items = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }    
    
    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);
        
    }

    handleChanges(event){
        this.displayError = false;
        event.preventDefault();
        if(JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()) != '[]') {
        insertUpdateOrderProducts({ orderProductListJson: JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()) , orderId: this.recordId })
    .then(
        
        result => { 
            //Fire event to the Order Product Component on the page 
        fireEvent(this.pageRef, 'inputChangeEvent', '');
    })
    .catch(error => {
        this.error = error;
        this.contacts = undefined;
    });
}
else {
    this.displayError = true;
}
    }
    //activateOrder() {
       // console.log(this.recordId );
       //activateOrder({ orderId: this.recordId  })

   // }
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }

    unSelect(event)
    {
        this.displayError = false; 
    }

}