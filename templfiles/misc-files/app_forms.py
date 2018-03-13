
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
    example_string1 = forms.Charfield(label='example label1', max_length=100)
    example_strin2 = forms.Charfield(label='example label2', max_length=200)
