/**
 * The "table" object is the single object used by APPRIS Library.
 * It contains utility function for setting up the reporting tables of appris interface.
 * @title  APPRIS
 * @module table
 * @author Jose Manuel Rodriguez CNIO-INB (jmrodriguez@cnio.es)
 * @version 0.1
 */

/**
 * table is an abstract base class.
 * It is defined by means of list of elements that composed by itself.
 * @constructor
 * @param {String} sClass Class of table
 * @param {Array} aHead The list of elements of head
 * @param {Array} aBody The list of elements of body
 */
function table (sClass, aHead, aBody)
{
	this.sId = '';
	this.sClass = sClass;
	this._createHTMLElement(aHead, aBody);
};

table.prototype = {

/* ATTRIBUTES */
	/**
	* The id of table
	* @type String
	*/
	sId: "",

	/**
	* The class of table
	* @type String
	*/
	sClass: "",
	
	/**
	* The dom element instance
	* @type Object
	*/
	oTable: null,

/* Private METHODS */

	/**
	* Create "html" element
	* @private
	* @param {Array} aHead The list of elements of head
	* @param {Array} aBody The list of elements of body 
	*/
	_createHTMLElement: function (aHead, aBody)
	{
		// parent node
		var oParent = document.createElement("span");
		
		// center node
		var oCenter = document.createElement("center");
		oParent.appendChild(oCenter);

		// table node
		var oTable = document.createElement("table");
		oTable.setAttribute("id", this.sId);
		oTable.setAttribute("class", this.sClass);
		oCenter.appendChild(oTable);
		
		// thead node
		if (aHead != null) {
			var oTHead = document.createElement("thead");
			var oTR = document.createElement("tr");
			oTHead.appendChild(oTR);
			for (var i = 0; i < aHead.length; i++) {
				var oTH = document.createElement("th");
				var oTextNode = document.createTextNode(aHead[i]);
				oTH.appendChild(oTextNode);
				oTR.appendChild(oTH);
			}			
		}		
		oTable.appendChild(oTHead);
		
		// tbody node
		if (aBody != null) {
			var oTBody = document.createElement("tbody");
			for (var sId in aBody) {
				var oTR = document.createElement("tr");
				oTBody.appendChild(oTR);
	
				var oTH = document.createElement("th");
				var oTextNode = document.createTextNode(sId);
				oTH.appendChild(oTextNode);
				oTR.appendChild(oTH);		
				
				for (var sLabel in aBody[sId]) {
					var sVal = aBody[sId][sLabel];
					var oTD = document.createElement("td");
					oTD.innerHTML = sVal;				
					oTR.appendChild(oTD);			
				}
			}
			oTable.appendChild(oTBody);		
		}
		
		this.oTable = oParent;		
	},

/* Public METHODS */

	/**
	* Return the HTML element of table
	* @return {String} sHTML inner html
	*/
	getHTMLElement: function ()
	{
		return this.oTable.innerHTML;		
	},
	
};
