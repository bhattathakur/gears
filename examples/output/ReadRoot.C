{
	gROOT->Reset();
	TString pdg="22"; //pdg number for the incident particle
	TString particle="gamma";     //Incident Particle
	TString target="Ge";   //Target Material
		
	TString filename="output";   //given filename
	//output.root is created by running radiate.mac with gears application
	TFile *file = new TFile(filename+".root");//opening the output root file
	//t->Show(0); //showing the event 1
	TCanvas *can=new TCanvas("c","c",1000,2000);
	
	//Creating a latext text to mention given particle and target
	TLatex lt;
	lt.SetTextSize(0.02);
	lt.DrawLatexNDC(0.05,0.495,"#"+particle+"->"+target);
	can->Divide(1,2); //Dividing a canvas into two Pads
	
	//pad 1
	can->cd(1);
	t->Draw("x");
	htemp->SetLineColor(2); //red color
	htemp->SetTitle("Histogram showing interactions along x direction");
	t->Draw("x","pdg=="+pdg,"same");//Draw takes branch-name,selection and option

	TH1F *h=(TH1F*)(gPad->GetListOfPrimitives()->At(1)); //get the primitives at 1
	h->SetLineColor(3);//green color
	
	//Adding a legend 
	auto legend=new TLegend(0.7,0.2,0.9,0.3);
	legend->AddEntry(htemp,"histogram for x","l");
	legend->AddEntry(h,"histogram for x for particle #"+particle,"l");
	legend->Draw();
//	gPad->SetFillColor(20);//color of this pad

	//pad 2
	can->cd(2);
	t->Draw("z:y");
//	gPad->SetFillColor(33);//color of this pad
	//gPad->Modified();
	//gPad->Update();
	//TGraph *f = (TGraph*)(gPad->GetPrimitive("Graph"))->Clone();
	//f->SetTitle("testing;;");
//	can->SetFillColor(17);
	can->SaveAs(filename+particle+target+".png")

}
