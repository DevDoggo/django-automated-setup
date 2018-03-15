
from django import forms
from .models import models, ExampleModel

class ExampleModelForm(forms.ModelForm):
    class Meta: 
        model = ExampleModel 
        fields = [
            'example_string1',
            'example_string2',
        ]


class ExampleForm(forms.Form):
    example_string1 = forms.CharField(label='example label in forms.py', max_length=100, required=False)
    example_string2 = forms.CharField(label='example label2', max_length=200)
