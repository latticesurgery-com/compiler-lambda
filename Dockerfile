FROM public.ecr.aws/lambda/python:3.9

# Copy function code
COPY function ${LAMBDA_TASK_ROOT}
COPY package/python ${LAMBDA_TASK_ROOT}/env
ENV PYTHONPATH=${LAMBDA_TASK_ROOT}/env

# Install the function's dependencies using file requirements.txt
# from your project folder.

#COPY requirements.txt  .
#RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.lambda_handler" ] 