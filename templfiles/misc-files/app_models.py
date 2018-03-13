from django.db import models

# Create your models here.

class ExampleModel(models.Model):
    example_string1 = models.CharField(max_length=100)
    example_string2 = models.CharField(max_length=200)


