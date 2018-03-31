from django.shortcuts import render
from django.http import HttpResponse

from .forms import ExampleForm, ExampleModelForm

# Create your views here.

def index(request):
    form = ExampleForm()
    model_form = ExampleModelForm()
    if request.method == "POST":
        print("\n\nThis is what you input when you pressed one of the buttons: ") 
        for key, value in request.POST.items():
            print (key, ":", value) 
        print("\n")

    varExample = "This is a customizeable variable!"
    context = { 'form':form, 'model_form':model_form, 'varExampleName':varExample }
    return render(request, 'body.html', context)
       
