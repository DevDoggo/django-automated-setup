from django.shortcuts import render
from django.http import HttpResponse

from .forms import ExampleForm

# Create your views here.

def index(request):
    form = ExampleForm()
    if request.method == "POST":
        print("\n\nThis is what you input when you pressed the 'Press me!' button: ") 
        for key, value in request.POST.items():
            print (key, ":", value) 
        print("\n")

    varExample = "This is a customizeable variable!"
    context = { 'form':form, 'varExampleName':varExample }
    return render(request, 'body.html', context)
       
