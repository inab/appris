/*
 * 
 * Methods of 'Download' panel
 * 
 */

/**
* Create HTML response for Download report
* @private
* @return {String} sResponse1 HTML response
*/
function printAPPRISDownload()
{
	// print the download panel of the main annotations of appris
	var sResponse1 = '';
	sResponse1 += 	"<ul>"+
						"<li>"+
							"<div class='main_download'><b>List of Principal Isoforms:</b></div>"+
							"A list of the transcripts predicted by APPRIS to code for the main isoform (PRINCIPAL). "+
							"APPRIS selects principal isoforms based on a range of protein features. "+
							"Where APPRIS is not able to distinguish a main isoform via these protein features, "+
							"it selects the variant with the longest protein sequence among those isoforms that APPRIS considers as candidate isoforms (LONGEST)."+
							"<p/>"+
						"</li>"+
						"<li>"+
							"<div class='main_download'><b>List of Principal/Potential Isoforms:</b></div>"+
							"A list of the transcripts predicted by APPRIS to code for the main isoform (PRINCIPAL). "+
							"APPRIS selects principal isoforms based on a range of protein features. "+
							"Where APPRIS is not able to distinguish a main isoform via these protein features, "+
							"the variant is labeled as POTENTIAL isoform."+
							"<p/>"+
						"</li>"+
						"<li>"+
							"<div class='main_download'><b>APPRIS Scores:</b></div>"+
							"APPRIS detects principal isoforms based on a range of methods, the scores they report can be downloaded here."+
							"<p/>"+							
						"</li>"+
						"<li>"+
							"<div class='main_download'><b>Exons annotated as Principal:</b></div>"+
							"Exons of variants predicted to code for the principal isoform."+
							"<p/>"+
						"</li>"+
						"For more information, click on \"i\" image."+						
					"</ul>";
	sResponse1 += "<center>"+
					"<table class='dpanel'>"+
					"<thead>"+	
						"<tr>"+
							"<th>Species</th>"+
							"<th>List of Principal Isoforms</th>"+
							"<th>List of Principal/Potential Isoforms</th>"+
							"<th>Score of APPRIS methods</th>"+
							"<th>Exons annotated as Principal</th>"+
						"</tr>"+
					"</thead>"+
					"<tbody>";
	sResponse1 +=  		"<tr>" +
							"<th><strong><i>Homo sapiens</i></strong><br/>(APPRIS - g15.v3.15Jul2013 - Gencode15/Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.principal.homo_sapiens.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.potential.homo_sapiens.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.appris_score.homo_sapiens.txt.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.conserved_exons.homo_sapiens.txt.gz'>TSV</a></b></td>" +
						"</tr>";
	sResponse1 +=  		"<tr>" +
							"<th><strong><i>Mus musculus</i></strong><br/>(APPRIS - e70.v3.15Jul2013 - Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.principal.mus_musculus.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.potential.mus_musculus.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.appris_score.mus_musculus.txt.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.conserved_exons.mus_musculus.txt.gz'>TSV</a></b></td>" +
						"</tr>";
	sResponse1 +=  		"<tr>" +
							"<th><strong><i>Rattus norvegicus</i></strong><br/>(APPRIS - e70.v3.10Jul2013 - Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.principal.rattus_norvegicus.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.potential.rattus_norvegicus.tsv.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.appris_score.rattus_norvegicus.txt.gz'>TSV</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.conserved_exons.rattus_norvegicus.txt.gz'>TSV</a></b></td>" +
						"</tr>";					
	sResponse1 += "</tbody>"+
				"</table>"+
				"</center>";
	
	
	var sResponse2 = '';
	sResponse2 += "<br /><br />";
	sResponse2 += "APPRIS detects principal isoforms based on a range of methods. Here we show APPRIS tracks as genome coordinate positions (in GTF format) of the following methods:";	
	sResponse2 += "<center>"+
					"<table class='dpanel'>"+
					"<thead>"+	
						"<tr>"+
							"<th>Species</th>"+
							"<th>No. Functional Residues</th>"+
							"<th>Tertiary Structure Score</th>"+
							"<th>Conservation Score (vertebrates)</th>"+
							"<th>Whole Domains</th>"+
							"<th>No. Transmembrane Helices</th>"+
						"</tr>"+
					"</thead>"+
					"<tbody>";
	sResponse2 +=  		"<tr>" +
							"<th><strong><i>Homo sapiens</i></strong><br/>(APPRIS - g15.v3.15Jul2013 - Gencode15/Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.firestar.homo_sapiens.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.matador3d.homo_sapiens.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.corsair.homo_sapiens.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.spade.homo_sapiens.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.thump.homo_sapiens.gtf.gz'>GTF</a></b></td>" +
						"</tr>";
	sResponse2 +=  		"<tr>" +
							"<th><strong><i>Mus musculus</i></strong><br/>(APPRIS - e70.v3.15Jul2013 - Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.firestar.mus_musculus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.matador3d.mus_musculus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.corsair.mus_musculus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.spade.mus_musculus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.thump.mus_musculus.gtf.gz'>GTF</a></b></td>" +
						"</tr>";
	sResponse2 +=  		"<tr>" +
							"<th><strong><i>Rattus norvegicus</i></strong><br/>(APPRIS - e70.v3.10Jul2013 - Ensembl70)</th>" +
							"<td><b><a href='../download/data/appris_data.firestar.rattus_norvegicus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.matador3d.rattus_norvegicus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.corsair.rattus_norvegicus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.spade.rattus_norvegicus.gtf.gz'>GTF</a></b></td>" +
							"<td><b><a href='../download/data/appris_data.thump.rattus_norvegicus.gtf.gz'>GTF</a></b></td>" +
						"</tr>";					
	sResponse2 += "</tbody>"+
				"</table>"+
				"</center>";
				
	var sResponse = sResponse1 + sResponse2;
	return sResponse;
}

/**
* Create HTML response for mysqldump report
* @private
* @return {String} sResponse1 HTML response
*/
function printAPPRISmysqldump()
{
	// print the download panel of the main annotations of appris
	var sResponse = '';
	sResponse += 	"<div id='download_panel'>"+
					"<center>"+
						"<table class='dpanel'>"+
						"<thead>"+	
							"<tr>"+
								"<th>Species</th>"+
								"<th>Database dumps</th>"+
							"</tr>"+
						"</thead>"+
						"<tbody>";
	sResponse +=  		"<tr>" +
							"<th><strong><i>Homo sapiens</i></strong><br/>(APPRIS - g15.v3.15Jul2013 - Gencode15/Ensembl70)</th>" +
							"<td style='text-align: center'><b><a href='../download/mysql/appris_db.homo_sapiens.dump.gz'>MySQL</a></b></td>" +
						"</tr>";
	sResponse +=  		"<tr>" +
							"<th><strong><i>Mus musculus</i></strong><br/>(APPRIS - e70.v3.15Jul2013 - Ensembl70)</th>" +
							"<td style='text-align: center'><b><a href='../download/mysql/appris_db.mus_musculus.dump.gz'>MySQL</a></b></td>" +
						"</tr>";
	sResponse +=  		"<tr>" +
							"<th><strong><i>Rattus norvegicus</i></strong><br/>(APPRIS - e70.v3.10Jul2013 - Ensembl70)</th>" +
							"<td style='text-align: center'><b><a href='../download/mysql/appris_db.rattus_norvegicus.dump.gz'>MySQL</a></b></td>" +
						"</tr>";					
	sResponse += 		"</tbody>"+
						"</table>"+
					"</center>"+
					"</div>";
				
	return sResponse;
}