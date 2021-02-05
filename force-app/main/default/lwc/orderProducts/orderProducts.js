import { LightningElement, wire, api, track} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProductsInit from '@salesforce/apex/OrderProductsController.getOrderProductsInit';
import getOrderProductOnChange from '@salesforce/apex/OrderProductsController.getOrderProductOnChange';

import{CurrentPageReference}
      from 'lightning/navigation';
      import { registerListener, unregisterAllListeners } from 'c/pubSub';

const columns = [{
        label: 'Name',
        fieldName: 'Product2.Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        sortable: true
    },

    {
        label: 'Total Price',
        fieldName: 'TotalPrice',
        sortable: true
    },

    {
        label: 'Quantity',
        fieldName: 'Quantity',
        sortable: true
    }

   
];

export default class Productorder extends LightningElement {
    @wire(CurrentPageReference) pageRef
    @track value;
    @track error;
    @track data;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
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
  
    @wire(getOrderProductsInit, { orderId: '$recordId' })
    
    wiredAccounts({ error, data }) {
        if (data) {
           
            this.items = data.map(
                record => Object.assign({ "Product2.Name": record.Product2.Name}, record ));
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
//get Event from first Component  
 connectedCallback(){
    registerListener('inputChangeEvent', this.handleEvent, this);
}

handleEvent(){
    
    getOrderProductOnChange({ orderId: this.recordId })
    .then(
        result => {
        this.data = result.map(
            record => Object.assign({ "Product2.Name": record.Product2.Name}, record ));;
        this.error = undefined;
       
    })
    .catch(error => {
        this.error = error;
    });
}

disconnectedCallback(){
    unregisterAllListeners(this);
}

}